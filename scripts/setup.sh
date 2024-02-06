# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

if [ -z "$DEMO_WORKSPACE" ]; then
    DEMO_WORKSPACE=./workspaces/demo
fi

if [ -z "$CCF_VERSION" ]; then
    CCF_VERSION="5.0.0-dev10"
fi

if [ -z "$KMS_REV" ]; then
    KMS_REV="main"
fi

if [ -z "$BA_REV" ]; then
    BA_REV="add-azure-support"
fi

if [ -z "$DATA_PLANE_REV" ]; then
    DATA_PLANE_REV="add-azure-support"
fi

REPO_PATH=$(realpath $(dirname "$0")/..)

# Install CCF
if [ ! -d "/opt/ccf_virtual"]; then
  (
    cd /tmp
    wget https://github.com/microsoft/CCF/releases/download/ccf-${CCF_VERSION}/ccf_virtual_${CCF_VERSION//-/_}_amd64.deb -O ccf_virtual_${CCF_VERSION//-/_}_amd64.deb
    sudo apt-get update && sudo apt install -y ./ccf_virtual_${CCF_VERSION//-/_}_amd64.deb
    /opt/ccf_virtual/getting_started/setup_vm/run.sh \
        /opt/ccf_virtual/getting_started/setup_vm/app-dev.yml \
        --extra-vars "platform=virtual" --extra-vars "clang_version=15"
  )
fi

# Checkout KMS code
if [ ! -d "$DEMO_WORKSPACE/azure-privacy-sandbox-kms" ]; then
    git clone https://github.com/microsoft/azure-privacy-sandbox-kms $DEMO_WORKSPACE/azure-privacy-sandbox-kms
    (cd $DEMO_WORKSPACE/azure-privacy-sandbox-kms && git checkout $KMS_REV)
else
    echo "KMS already checked out"
    echo "If you want to guarantee KMS_REV is respected, call this script with fresh DEMO_WORKSPACE"
fi

# Checkout B&A code
if [ ! -d "$DEMO_WORKSPACE/bidding-auction-servers" ]; then
    git clone https://github.com/kengordon/bidding-auction-servers $DEMO_WORKSPACE/bidding-auction-servers
    (cd $DEMO_WORKSPACE/bidding-auction-servers && git checkout $BA_REV)
    git clone https://github.com/kengordon/data-plane-shared-libraries $DEMO_WORKSPACE/bidding-auction-servers/data-plane-shared-libraries
    (cd $DEMO_WORKSPACE/bidding-auction-servers/data-plane-shared-libraries && git checkout $DATA_PLANE_REV)

    # Apply a patch to the B&A code to use the local data-plane-shared-libraries
    (cd $DEMO_WORKSPACE/bidding-auction-servers && git apply $REPO_PATH/patches/use_local_data_plane.patch)
else
    echo "B&A already checked out"
    echo "If you want to guarantee BA_REV and DATA_PLANE_REV are respected, call this script with fresh DEMO_WORKSPACE"
fi
