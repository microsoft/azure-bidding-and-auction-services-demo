
if [ -z "$DEMO_WORKSPACE" ]; then
    DEMO_WORKSPACE=~/demo
fi

if [ -z "$KMS_REV" ]; then
    KMS_REV="beejones/initial-setup"
fi

if [ -z "$BA_REV" ]; then
    BA_REV="main"
fi

if [ -z "$DATA_PLANE_REV" ]; then
    DATA_PLANE_REV="main"
fi

REPO_PATH=$(realpath $(dirname "$0")/..)

# Checkout KMS code
if [ ! -d "$DEMO_WORKSPACE/azure-privacy-sandbox-kms" ]; then
    git clone git@github.com:microsoft/azure-privacy-sandbox-kms.git $DEMO_WORKSPACE/azure-privacy-sandbox-kms # TODO: When repo is public, use https
    # git clone https://github.com/microsoft/azure-privacy-sandbox-kms $DEMO_WORKSPACE/azure-privacy-sandbox-kms
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