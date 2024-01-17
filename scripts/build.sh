
if [ -z "$DEMO_WORKSPACE" ]; then
    DEMO_WORKSPACE=~/demo
fi

if [ -z "$USE_CBUILD" ]; then
    USE_CBUILD=1
fi

if [ -z "$CCF_VERSION" ]; then
    CCF_VERSION="5.0.0-dev10"
fi

# Build KMS
(
    cd $DEMO_WORKSPACE/azure-privacy-sandbox-kms
    docker build \
        --build-arg BASE_CCF_IMAGE=CCF_VERSION \
        -t kms \
        -f .devcontainer/Dockerfile.devcontainer .
)

# Build B&A Servers
(
    cd $DEMO_WORKSPACE/bidding-auction-servers
    if [ $USE_CBUILD -eq 1 ]; then
        BAZEL="builder/tools/bazel-debian"
    else
        BAZEL="bazel"
    fi
    $BAZEL build \
        //services/auction_service:server \
        //seller_frontend_service:server \
        //bidding_service:server \
        //buyer_frontend_service:server \
        //tools/secure_invoke:invoke \
        --config=azure_azure --//:build_flavor=non_prod
)