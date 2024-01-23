# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

if [ -z "$DEMO_WORKSPACE" ]; then
    DEMO_WORKSPACE=~/demo
fi

if [ -z "$USE_CBUILD" ]; then
    USE_CBUILD=1
fi

# Build KMS
(
    cd $DEMO_WORKSPACE/azure-privacy-sandbox-kms
    npm install
    make build
)

# Build B&A Servers
(
    cd $DEMO_WORKSPACE/bidding-auction-servers
    if [ $USE_CBUILD -eq 1 ]; then
        BAZEL="builders/tools/bazel-debian"
    else
        BAZEL="bazel"
    fi
    $BAZEL build \
        //services/auction_service:server \
        //services/seller_frontend_service:server \
        //services/bidding_service:server \
        //services/buyer_frontend_service:server \
        //tools/secure_invoke:invoke \
        --//:build_flavor=non_prod \
        --config=azure_azure
)