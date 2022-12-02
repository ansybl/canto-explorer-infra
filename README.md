# Canto Explorer Infra

<https://canto-evm-testnet.ansybl.io>

Automates the [BlockScout](https://github.com/blockscout/blockscout) deployment to Goole Cloud Platform for Canto.

Currently configured to consume testnet RPC nodes deployed via https://github.com/ansybl/canto-validator-infra

## Build & Deploy
Build locally and deploy to GCP Cloud Run.
```sh
export WORKSPACE=dev
make explorer/extract
make docker/build
make docker/login
make docker/push
make devops/terraform/plan
make devops/terraform/apply
```
We leverage [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) to handle state data instance separation.
In our setup the `WORKSPACE` matches with the network (e.g. `dev`, `prod`), but can also be used to stand up a dedicated dev instance (e.g. `dev-<name>`).

## Run the explorer locally
Run locally, useful for testing and debugging.
Via docker:
```sh
make docker/build
make docker/run
```
Without docker:
```sh
make explorer/run
```
