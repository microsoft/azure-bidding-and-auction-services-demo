ARG BASE_IMAGE=ubuntu:20.04

FROM ${BASE_IMAGE} as libprofiler-builder
COPY .devcontainer/scripts/ /scripts/
ENV CC=clang \
    CXX=clang
ADD https://github.com/gperftools/gperftools/releases/download/gperftools-2.13/gperftools-2.13.tar.gz /build/gperftools.tar.gz
ADD https://apt.llvm.org/llvm.sh /build/llvm.sh
RUN /scripts/compile_libprofiler

FROM docker/buildx-bin:v0.10 AS buildx-bin

FROM ${BASE_IMAGE}
ARG LOCALE=en_US.UTF-8
ARG TARGETARCH
COPY .devcontainer/scripts/* /scripts/
COPY .devcontainer/scripts/get_workspace_mount /usr/local/bin
COPY .devcontainer/scripts /etc
COPY --from=buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx
COPY --from=libprofiler-builder /usr/lib/libprofiler.so.* /usr/lib/x86_64-linux-gnu/
RUN \
    ln -rs /usr/lib/x86_64-linux-gnu/libprofiler.so.0.* /usr/lib/x86_64-linux-gnu/libprofiler.so.0 && \
    ln -rs /usr/lib/x86_64-linux-gnu/libprofiler.so.0.* /usr/lib/x86_64-linux-gnu/libprofiler.so
ENV BUILD_ARCH="${TARGETARCH}" \
    WORKSPACE=/src/workspace \
    CC=clang \
    TZ=Etc/UTC \
    LANG=${LOCALE} \
    LANGUAGE=${LOCALE} \
    LC_ALL=${LOCALE} \
    LC_CTYPE=${LOCALE}
RUN \
    chmod 644 /etc/gitconfig && \
    /scripts/install_apps --locale ${LOCALE} && \
    /scripts/generate_system_bazelrc --user-root-name ubuntu && \
    /scripts/install_golang_apps && \
    rm -rf /scripts

ENV PATH="/opt/bin:${PATH}:/usr/local/go/bin" \
    PYTHON_LIB_PATH="/usr/lib/python3.9"

# Custom Deps
RUN apt-get update && apt-get install -y \
    openssh-client \
    make \
    libuv1 \
    jq \
    lsof \
    sudo \
    python3.8-venv \
    nc

ENV USE_CBUILD=0