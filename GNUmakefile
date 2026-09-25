.PHONY: default
default: lint

.DELETE_ON_ERROR:

IMAGE ?= marshallford-me
IMAGE_TAG ?= ci
IMAGE_WITH_TAG := $(IMAGE):$(IMAGE_TAG)

PORT ?= 8080
CACHE_DIR := .cache
IMAGE_TAR := $(CACHE_DIR)/trivy-image.tar

CONTAINER_FLAGS += --rm
ifeq ($(shell tty > /dev/null && echo 1 || echo 0), 1)
CONTAINER_FLAGS += -i
endif

CONTAINER_RUNTIME ?= docker
CONTAINER_MOUNT_FLAGS := ro,z
CONTAINER_RUN := $(CONTAINER_RUNTIME) run $(CONTAINER_FLAGS)
CONTAINER_PULL := $(CONTAINER_RUNTIME) pull -q

EDITORCONFIG_CHECKER_VERSION ?= 4.0.1
EDITORCONFIG_CHECKER_IMAGE ?= docker.io/mstruebing/editorconfig-checker:$(EDITORCONFIG_CHECKER_VERSION)
EDITORCONFIG_CHECKER := $(CONTAINER_RUN) -v=$(CURDIR):/check:$(CONTAINER_MOUNT_FLAGS) $(EDITORCONFIG_CHECKER_IMAGE)

YAMLLINT_VERSION ?= 0.35.13
YAMLLINT_IMAGE ?= docker.io/pipelinecomponents/yamllint:$(YAMLLINT_VERSION)
YAMLLINT := $(CONTAINER_RUN) -v=$(CURDIR):/code:$(CONTAINER_MOUNT_FLAGS) $(YAMLLINT_IMAGE) yamllint

CHECKOV_VERSION ?= 3.3.17
CHECKOV_IMAGE ?= docker.io/bridgecrew/checkov:$(CHECKOV_VERSION)
CHECKOV := $(CONTAINER_RUN) -v=$(CURDIR):/tf:$(CONTAINER_MOUNT_FLAGS) -w=/tf $(CHECKOV_IMAGE)

IMAGEMAGICK_VERSION ?= 7.1.2-12
IMAGEMAGICK_IMAGE ?= docker.io/dpokidov/imagemagick:$(IMAGEMAGICK_VERSION)
IMAGEMAGICK := $(CONTAINER_RUN) -v=$(CURDIR):/imgs:z $(IMAGEMAGICK_IMAGE)

TRIVY_VERSION ?= 0.74.0
TRIVY_IMAGE ?= docker.io/aquasec/trivy:$(TRIVY_VERSION)
TRIVY_VOLUME := trivy-cache
TRIVY := $(CONTAINER_RUN) -v=$(CURDIR)/$(CACHE_DIR):/scan:$(CONTAINER_MOUNT_FLAGS) -v=$(TRIVY_VOLUME):/root/.cache/trivy $(TRIVY_IMAGE)

GITHUB_REPOSITORY := marshallford/marshallford.me
PUBLISH_WORKFLOW := .github/workflows/terraform.yaml
COSIGN ?= cosign
GH ?= gh

VERIFY_CONTAINER_IMAGE ?= us-central1-docker.pkg.dev/marshallford-marshallford-me/containers/marshallford-me:latest
VERIFY_CERT_IDENTITY := https://github.com/$(GITHUB_REPOSITORY)/$(PUBLISH_WORKFLOW)@refs/heads/main
VERIFY_OIDC_ISSUER := https://token.actions.githubusercontent.com
VERIFY_SIGNER_WORKFLOW := $(GITHUB_REPOSITORY)/$(PUBLISH_WORKFLOW)
VERIFY_SBOM_PREDICATE_TYPE ?= https://spdx.dev/Document/v2.3

TERRAFORM ?= terraform
NPM ?= npm
NODE ?= node
export HUGO_PARAMS_COMMIT ?= $(shell git rev-parse HEAD)
HUGO := ./node_modules/.bin/hugo
LHCI := ./node_modules/.bin/lhci

.PHONY: pull pull/editorconfig pull/yamllint pull/checkov pull/trivy pull/imagemagick
pull: pull/editorconfig pull/yamllint pull/checkov pull/trivy pull/imagemagick

pull/imagemagick:
	$(CONTAINER_PULL) $(IMAGEMAGICK_IMAGE)

pull/editorconfig:
	$(CONTAINER_PULL) $(EDITORCONFIG_CHECKER_IMAGE)

pull/yamllint:
	$(CONTAINER_PULL) $(YAMLLINT_IMAGE)

pull/checkov:
	$(CONTAINER_PULL) $(CHECKOV_IMAGE)

pull/trivy:
	$(CONTAINER_PULL) $(TRIVY_IMAGE)

node_modules: package-lock.json
	$(NPM) ci
	@touch $@

.PHONY: lint lint/editorconfig lint/yamllint lint/terraform
lint: lint/editorconfig lint/yamllint lint/terraform

lint/editorconfig:
	$(EDITORCONFIG_CHECKER)

lint/yamllint:
	$(YAMLLINT) .

lint/terraform:
	$(TERRAFORM) -chdir=terraform fmt -recursive -check -diff

.PHONY: fmt fmt/terraform
fmt: fmt/terraform

fmt/terraform:
	$(TERRAFORM) -chdir=terraform fmt -recursive

.PHONY: build build/hugo build/compress build/container build/favicon
build: build/hugo build/compress

build/hugo: node_modules
	$(HUGO) --minify --cleanDestinationDir --panicOnWarning --templateMetrics --templateMetricsHints

build/compress: build/hugo
	$(NODE) scripts/precompress.mjs public

build/container:
	$(CONTAINER_RUNTIME) build --pull --build-arg=HUGO_PARAMS_COMMIT=$(HUGO_PARAMS_COMMIT) . -t $(IMAGE_WITH_TAG)

build/favicon:
	$(IMAGEMAGICK) -size 512x512 xc:black -fill white -draw "circle 255.5,255.5 255.5,0" \
		-colorspace Gray -depth 8 -strip /imgs/assets/images/circle-mask.png
	$(IMAGEMAGICK) /imgs/assets/images/me.jpg -resize 32x32 /imgs/assets/images/circle-mask.png \
		-resize 32x32 -compose CopyOpacity -composite -define icon:auto-resize=32 /imgs/static/favicon.ico

.PHONY: serve serve/hugo serve/container
serve: serve/hugo

serve/hugo: node_modules
	$(HUGO) server -p $(PORT) --panicOnWarning

serve/container: build/container
	$(CONTAINER_RUN) -p $(PORT):$(PORT) -e=PORT=$(PORT) $(IMAGE_WITH_TAG)

.PHONY: test test/lighthouse
test: test/lighthouse

test/lighthouse: node_modules build/container
	$(LHCI) autorun

.PHONY: scan scan/checkov scan/trivy
scan: scan/checkov scan/trivy

scan/checkov:
	$(CHECKOV) --config-file checkov.yaml

scan/trivy: build/container
	mkdir -p $(CACHE_DIR)
	$(CONTAINER_RUNTIME) save $(IMAGE_WITH_TAG) -o $(IMAGE_TAR)
	$(TRIVY) image --input /scan/$(notdir $(IMAGE_TAR))

.PHONY: verify verify/image verify/sbom
verify: verify/image verify/sbom

verify/image:
	$(COSIGN) verify $(VERIFY_CONTAINER_IMAGE) \
		--certificate-identity $(VERIFY_CERT_IDENTITY) \
		--certificate-oidc-issuer $(VERIFY_OIDC_ISSUER) > /dev/null
	$(GH) attestation verify oci://$(VERIFY_CONTAINER_IMAGE) \
		--repo $(GITHUB_REPOSITORY) \
		--signer-workflow $(VERIFY_SIGNER_WORKFLOW)

verify/sbom:
	$(GH) attestation verify oci://$(VERIFY_CONTAINER_IMAGE) \
		--repo $(GITHUB_REPOSITORY) \
		--signer-workflow $(VERIFY_SIGNER_WORKFLOW) \
		--predicate-type $(VERIFY_SBOM_PREDICATE_TYPE)

.PHONY: clean
clean:
	rm -rf public resources/_gen node_modules $(IMAGE_TAR)
	$(CONTAINER_RUNTIME) volume rm -f $(TRIVY_VOLUME)
