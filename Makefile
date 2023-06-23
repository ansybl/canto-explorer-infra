IMAGE_TAG=latest
BLOCKSCOUT_VERSION=817ca1bf960bc053fe0b73d044bc12fbaad76cfa
BLOCKSCOUT_ARCHIVE=$(BLOCKSCOUT_VERSION).tar.gz
BLOCKSCOUT_REMOTE_ARCHIVE=https://github.com/blockscout/blockscout/archive/$(BLOCKSCOUT_ARCHIVE)
BLOCKSCOUT_DIRECTORY=blockscout-$(BLOCKSCOUT_VERSION)
PROJECT=dfpl-playground
REGISTRY=gcr.io/$(PROJECT)
WORKSPACE?=dev
IMAGE_NAME=blockscout-$(WORKSPACE)
DOCKER_IMAGE=$(REGISTRY)/$(IMAGE_NAME)
ifndef CI
DOCKER_IT=-it
endif


$(BLOCKSCOUT_ARCHIVE):
	wget $(BLOCKSCOUT_REMOTE_ARCHIVE)

explorer/download: $(BLOCKSCOUT_ARCHIVE)

$(BLOCKSCOUT_DIRECTORY): explorer/download
	tar -xvf $(BLOCKSCOUT_ARCHIVE)

explorer/extract: $(BLOCKSCOUT_DIRECTORY)

docker/build:
	cd $(BLOCKSCOUT_DIRECTORY) && \
	docker build --tag=$(DOCKER_IMAGE):$(IMAGE_TAG) \
	--build-arg CACHE_EXCHANGE_RATES_PERIOD="" \
	--build-arg DISABLE_READ_API="false" \
	--build-arg API_PATH="" \
	--build-arg NETWORK_PATH="/" \
	--build-arg DISABLE_WEBAPP="false" \
	--build-arg DISABLE_WRITE_API="false" \
	--build-arg CACHE_ENABLE_TOTAL_GAS_USAGE_COUNTER="" \
	--build-arg CACHE_ADDRESS_WITH_BALANCES_UPDATE_INTERVAL="" \
	--build-arg CACHE_ADDRESS_WITH_BALANCES_UPDATE_INTERVAL="/" \
	--build-arg WOBSERVER_ENABLED="false" \
	--build-arg ADMIN_PANEL_ENABLED="" \
	--file docker/Dockerfile .

docker/login:
	gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io

docker/push:
	docker push $(DOCKER_IMAGE):$(IMAGE_TAG)

docker/run:
	docker run $(DOCKER_IT) --publish 4000:4000 --env-file .env --rm $(DOCKER_IMAGE) \
	bash -c "bin/blockscout eval \"Elixir.Explorer.ReleaseTasks.create_and_migrate()\" && bin/blockscout start"

docker/run/sh:
	docker run $(DOCKER_IT) --env-file .env --rm $(DOCKER_IMAGE)

devops/terraform/select/%:
	terraform -chdir=terraform workspace select $* || terraform -chdir=terraform workspace new $*

devops/terraform/fmt:
	terraform -chdir=terraform fmt -recursive -diff

devops/terraform/init:
	terraform -chdir=terraform init -reconfigure

devops/terraform/plan: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform plan

devops/terraform/apply: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform apply -auto-approve

devops/terraform/output: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform output

devops/terraform/redeploy: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform apply \
	-replace=google_cloud_run_service.default \
	-target=google_cloud_run_service.default \
	-target=google_cloud_run_service_iam_policy.noauth \
	-target=google_cloud_run_domain_mapping.default

# https://github.com/terraform-google-modules/terraform-google-lb-http/blob/v6.3.0/docs/upgrading-v2.0.0-v3.0.0.md#dealing-with-dependencies
devops/terraform/destroy/serverless_neg: devops/terraform/select/$(WORKSPACE)
	terraform -chdir=terraform destroy \
	-target=google_compute_region_network_endpoint_group.serverless_neg -auto-approve
