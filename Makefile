# requires env vars: GOOGLE_CREDENTIALS, GOOGLE_PROJECT, GOOGLE_REGION
# FYI: GOOGLE_CREDENTIALS must be a single line. Use `cat sa.json | jq -c .` to format
ifndef GOOGLE_CREDENTIALS
$(error GOOGLE_CREDENTIALS is not set)
endif
ifndef GOOGLE_PROJECT
$(error GOOGLE_PROJECT is not set)
endif
ifndef GOOGLE_REGION
$(error GOOGLE_REGION is not set)
endif

default: serve

GIT_BRANCH ?= `git rev-parse --abbrev-ref HEAD`
GIT_COMMIT ?= `git rev-parse --short HEAD`

GITHUB_REPOSITORY ?= marshallford/marshallford.me
REGISTRY := gcr.io
IMAGE_NAME := $(REGISTRY)/$(GOOGLE_PROJECT)/marshallford-me
IMAGE := $(IMAGE_NAME):$(GIT_COMMIT)

ifeq (`tty > /dev/null && echo 1 || echo 0`, 1)
DOCKER_FLAGS := --rm -it
else
DOCKER_FLAGS := --rm
endif
DOCKER := docker

HUGO_VERSION ?= 0.74.3
HUGO_RELEASE := https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_extended_$(HUGO_VERSION)_Linux-64bit.tar.gz
HUGO := ./bin/hugo

TERRAFORM_VERSION ?= 0.13.0
TERRAFORM_RELEASE := https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip
ifdef CI
TERRAFORM := terraform
else
TERRAFORM := ./bin/terraform
endif

bin/dir:
	mkdir -p bin

bin/hugo: bin/dir
	$(eval TMP := $(shell mktemp -d))
	wget -q $(HUGO_RELEASE) -O $(TMP)/hugo.tar.gz
	tar -zxvf $(TMP)/hugo.tar.gz -C $(TMP)
	mv $(TMP)/hugo bin/hugo

bin/terraform: bin/dir
	$(eval TMP := $(shell mktemp -d))
	wget -q $(TERRAFORM_RELEASE) -O $(TMP)/terraform.zip
	unzip $(TMP)/terraform.zip -d $(TMP)
	mv $(TMP)/terraform bin/terraform

build: build/hugo
build/hugo:
	$(HUGO) --minify --cleanDestinationDir -b /

build/docker:
	$(DOCKER) build --pull . \
		--build-arg MAINTAINER="Marshall Ford <inbox@marshallford.me>" \
		--build-arg CREATED=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		--build-arg REVISION=$(GIT_COMMIT) \
		--build-arg VERSION=$(VERSION) \
		--build-arg TITLE=$(IMAGE_NAME) \
		--build-arg REPOSITORY_URL=https://github.com/$(GITHUB_REPOSITORY) \
		--build-arg HUGO_RELEASE=$(HUGO_RELEASE) \
		-t $(IMAGE)

docker-login:
	echo $$GOOGLE_CREDENTIALS | $(DOCKER) login -u _json_key --password-stdin https://$(REGISTRY)

docker-push:
	$(DOCKER) push $(IMAGE)

serve: serve/hugo
serve/hugo:
	$(HUGO) server -p 8080

serve/python: build
	python3 -m http.server -d public 8080

serve/docker: docker-build
	$(DOCKER) run $(DOCKER_FLAGS) -p 8080:8080 $(IMAGE)

terraform/init:
	$(TERRAFORM) init -backend=false

terraform/init/backend:
	$(TERRAFORM) init -backend=true

terraform/validate:
	$(TERRAFORM) validate

terraform/fmt:
	$(TERRAFORM) fmt -check -recursive -diff

terraform/fmt/fix:
	$(TERRAFORM) fmt -recursive

terraform/apply:
	$(TERRAFORM) apply -auto-approve --var="image=$(IMAGE)"

.PHONY: bin/dir bin/hugo bin/terraform build build/hugo build/docker \
				docker-login docker-push \
        serve serve/hugo serve/python serve/docker \
				terraform/init terraform/init/backend terraform/validate terraform/fmt terraform/fmt/fix terraform/apply
