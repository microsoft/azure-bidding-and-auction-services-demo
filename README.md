# Azure Privacy Sandbox Demo

- [Overview](#Overview)
- [Running Demo](#Running-Demo)
  - [Initial Setup](#Initial-Setup)
  - [Building](#Building)
  - [Running](#Running)
  - [Issuing Requests](#Issuing-Requests)
- [Contributing](#Contributing)
- [Trademarks](#Trademarks)

## Overview

This repository is a sample of how to locally run Azure's Privacy Sandbox implementation, which consists of the following components:

- [Bidding and Auction Servers](https://github.com/privacysandbox/bidding-auction-servers)

  This code is maintained by Google and will have contributions from Microsoft.
  It also depends on another Google maintained repository with Microsoft contributions called [Data Plane Shared Libraries](https://github.com/privacysandbox/data-plane-shared-libraries)

- [Key Management Service (KMS)](https://github.com/microsoft/azure-privacy-sandbox-kms)

  Written by Microsoft, based on the [Confidential Consortium Framework (CCF)](https://github.com/microsoft/ccf).
  The KMS is currently closed source, but with plans to open source.
  
## Running Demo

### Prerequisites

Opening this repository in a codespace or opening the [devcontainer](.devcontainer/devcontainer.json) will automatically have all the required dependencies.

Alternatively, you can run the parts of the devcontainer [Dockerfile](.devcontainer/Dockerfile) manually to setup your environment.

### Initial Setup

First, you can set the `DEMO_WORKSPACE` environment variable to configure where the KMS and B&A server code is checked out to.

Then, run [setup.sh](scripts/setup.sh)

```
./scripts/setup.sh
```
This does the following:
- Checks out the Microsoft fork of the Bidding and Auction Servers and the Data Plane Shared Libraries
- Checks out the Key Management System

### Building

To build the demo, run [build.sh](scripts/build.sh)
```
./scripts/build.sh
```

This builds a docker image for the KMS and uses Bazel to build the B&A server code.

### Running

To run the B&A servers and the KMS, run [run.sh](scripts/run.sh).
```
./scripts/run.sh
```

This runs the KMS docker container, and the Bidding and Auction servers. While this is running you can issue requests in a second terminal.

### Issuing Requests
You can issue requests with [request.sh](scripts/request.sh).
```
TARGET_SERVICE=bfe REQUEST_PATH=requests/get_bids_request.json ./scripts/request.sh
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
