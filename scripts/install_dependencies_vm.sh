#!/bin/bash

set -ex

DIR_OF_THIS_FILE=$(cd $(dirname $0); pwd)
PROJECT_ROOT=$DIR_OF_THIS_FILE/..
cd $PROJECT_ROOT

RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m'

CCF_DIR="/tmp/CCF"

if [ ! -d $CCF_DIR ]; then
  sudo git clone https://github.com/microsoft/CCF.git $CCF_DIR
  sudo chown -R $USER $CCF_DIR

  # Comment out a check to prevent using virtual build on SNP hardware
  LINES_TO_COMMENT=$(grep -n "Cannot verify virtual attestation report if node is SEV-SNP" $CCF_DIR/include/ccf/pal/attestation.h | cut -f1 -d:)
  sed -i "$((LINES_TO_COMMENT - 3)),$((LINES_TO_COMMENT + 1))s/^/\/\//" $CCF_DIR/include/ccf/pal/attestation.h
fi

if [ -d "/opt/ccf_virtual" ] && [ -d "$CCF_DIR/build" ]; then
  # Dependencies are already installed. Just recompiles CCF.
  (
    cd $CCF_DIR/build
    ninja
    sudo ninja install
  )
  exit 0
fi

sudo apt update -y
# For B&A
sudo apt install -y lsof gdb
# For KMS
sudo apt install -y protobuf-compiler

# Prevent the oficial docker .gpg file from causing error in
# $CCF_DIR/getting_started/setup_vm/run.sh
if [ -f "/etc/apt/sources.list.d/docker.list" ]; then
  sudo rm /etc/apt/sources.list.d/docker.list
  sudo rm /etc/apt/keyrings/docker.gpg
fi

(
  cd $CCF_DIR/getting_started/setup_vm/
  ./run.sh ccf-dev.yml --extra-vars "platform=virtual clang_version=15"
)

mkdir -p $CCF_DIR/build
pushd $CCF_DIR/build

CC=$(command -v clang-15 || true)
CXX=$(command -v clang++-15 || true)
CC=$CC CXX=$CXX cmake -GNinja -DCOMPILE_TARGET=virtual ..
# If the build fails, check the output and see if cmake recognized installed clang-15
# Otherwise you need to re-login and make sure clang-15 is installed

handle_build_error() {
  echo -e "${RED}If the build fails, check the cmake command output to see if it recognizes clang-15 which is required to build CCF.${RESET}"
  popd
  exit 1
}
trap 'handle_build_error' ERR
ninja
trap ':' ERR

sudo ninja install
popd

# Install docker
# Looks like $CCF_DIR/getting_started/setup_vm/run.sh
# adds docker.io and docker command, but doesn't add docker service.
# We need to do it manually
if ! groups $USER | grep -q '\bdocker\b' && [ "$NO_CBUILD" != "1" ]
then
  sudo apt install -y containerd docker.io
  sudo groupadd -f docker
  sudo usermod -aG docker $USER
  newgrp docker
fi

# `newgrp docker` should allow you to skip restart, but doesn't work for some unclear cases.
echo -e "${BLUE}Install finished. Restart the computer to enable non-sudo docker, and make sure your ssh key is added to ADO to clone privacy sandbox repositories.${RESET}"

