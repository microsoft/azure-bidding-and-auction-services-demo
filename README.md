# Azure Bidding & Auction Services Demo

This repository is a sample of how to locally run Azure's [Bidding and Auction Servers](https://github.com/privacysandbox/bidding-auction-servers) implementation. 

This code is maintained by Google with contributions from Microsoft to support running in Azure.
It also depends on another Google maintained repository with Microsoft contributions called [Data Plane Shared Libraries](https://github.com/privacysandbox/data-plane-shared-libraries).

It depends on the Azure Privacy Sandbox  [Key Management Service (KMS)](https://github.com/microsoft/azure-privacy-sandbox-kms), which is written by Microsoft, and based on the [Confidential Consortium Framework (CCF)](https://github.com/microsoft/ccf).

## Table of Contents

- [Running](#Running)
  - [Initial Setup](#Initial-Setup)
  - [Building](#Building)
  - [Running](#Running)
  - [Issuing Requests](#Issuing-Requests)
- [Contributing](#Contributing)
- [Trademarks](#Trademarks)

## Running

### Prerequisites

Here are three simple ways to setup an environment for running the demo, in order of the preferred options:

#### Codespaces

Opening in a codespace will automatically have all required dependencies, we recommend using larger containers as building the Bidding and Auction server code is slow.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=740915196&skip_quickstart=true&machine=premiumLinux&geo=EuropeWest)

#### Devcontainer

Opening the repository in the [devcontainer](.devcontainer/devcontainer.json) will also automatically have all required dependencies

#### Manually

You can refer to the [Dockerfile](.devcontainer/Dockerfile) which the devcontainer is built with to install all dependencies manually

### Initial Setup

To setup a directory with the B&A and KMS code, run [setup.sh](scripts/setup.sh).

```
./scripts/setup.sh
```

This does the following:
- Installs CCF
- Checks out the Key Management System
- Checks out the Microsoft fork of the Bidding and Auction Servers and the Data Plane Shared Libraries

*NOTE: These repositories are checked out with HTTP and are therefore read only. To have write access, change the remote to SSH and setup your key as usual.*

#### Configurable Envionment Variables

| Name | Default | Description |
|------|-------------|---------|
| `DEMO_WORKSPACE` | `./workspaces/demo` | Path to the directory where `setup.sh` will checkout the KMS and B&A code |
| `CCF_VERSION` | `5.0.0-dev10` | Version of CCF to run the KMS against |
| `KMS_REV` | `main` | Revision of the KMS to checkout |
| `BA_REV` | `main` | Revision of the B&A Services to checkout |
| `DATA_PLANE_REV` | `main` | Revision of the Data Plance Shared Libraries to checkout |


### Building

To build the demo, run [build.sh](scripts/build.sh).
```
./scripts/build.sh
```

This builds the KMS and the Bidding and Auction server code. On a 32 core machine it takes ~30 minutes. You can setup a [remote Bazel cache](https://bazel.build/remote/caching) to speed up builds on multiple machines.

#### Configurable Envionment Variables

| Name | Default | Description |
|------|-------------|---------|
| `DEMO_WORKSPACE` | `./workspaces/demo` | Path to the directory where the KMS and B&A code to be built is |
| `USE_CBUILD` | `1` | Whether to use CBuild for building B&A Services, uses local Bazel if not 1 |

Bidding and Auction server code defaults to using CBuild to avoid manual dependency setup. The devcontainer and by extension codespace set this to 0 as Cbuild doesn't work inside a container.

### Running

To run the B&A servers and the KMS, run [run.sh](scripts/run.sh).
```
./scripts/run.sh
```

This runs the KMS and the Bidding and Auction servers. While this is running you can issue requests in a second terminal.

#### Configurable Envionment Variables

| Name | Default | Description |
|------|-------------|---------|
| `DEMO_WORKSPACE` | `./workspaces/demo` | Path to the directory where the KMS and B&A code to be run is |

### Issuing Requests
You can issue requests with [request.sh](scripts/request.sh).
```
./scripts/request.sh

# Example requests
TARGET_SERVICE=bfe REQUEST_PATH=requests/get_bids_request.json ./scripts/request.sh
TARGET_SERVICE=sfe REQUEST_PATH=requests/select_ads_request.json ./scripts/request.sh
```

#### Configurable Envionment Variables

| Name | Default | Description |
|------|-------------|---------|
| `DEMO_WORKSPACE` | `./workspaces/demo` | Path to the directory where the running KMS and B&A code is |
| `TARGET_SERVICE` | `bfe` | The service to send the request to |
| `REQUEST_PATH` | `requests/get_bids_request.json` | The path to the request to send (relative to repository root) |

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
