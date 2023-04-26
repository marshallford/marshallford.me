# TODO add support for checkov and trivy

default: serve
EXISTING_VARS := $(.VARIABLES)

IMAGE := gcr.io/marshallford-marshallford-me/marshallford-me
IMAGE_WITH_TAG := $(IMAGE):ci

DOCKER_FLAGS += --rm
ifeq ($(shell tty > /dev/null && echo 1 || echo 0), 1)
DOCKER_FLAGS += -i
endif
DOCKER := docker
DOCKER_RUN := $(DOCKER) run $(DOCKER_FLAGS)

EDITORCONFIG_CHECKER_VERSION ?= 2.4.0
EDITORCONFIG_CHECKER := $(DOCKER_RUN) -v=$(CURDIR):/check docker.io/mstruebing/editorconfig-checker:$(EDITORCONFIG_CHECKER_VERSION)

SHELLCHECK_VERSION ?= 0.9.0
SHELLCHECK := $(DOCKER_RUN) -v=$(CURDIR):/mnt docker.io/koalaman/shellcheck:v$(SHELLCHECK_VERSION)

YAMLLINT_VERSION ?= 0.23.0
YAMLLINT := $(DOCKER_RUN) -v=$(CURDIR):/code docker.io/pipelinecomponents/yamllint:$(YAMLLINT_VERSION) yamllint

DARTSASS_VERSION ?= 1.62.0
DARTSASS_RELEASE := https://github.com/sass/dart-sass-embedded/releases/download/$(DARTSASS_VERSION)/sass_embedded-$(DARTSASS_VERSION)-linux-x64.tar.gz
DARTSASS ?= ./.bin/dart-sass/$(DARTSASS_VERSION)/dart-sass-embedded

HUGO_VERSION ?= 0.111.3
HUGO_RELEASE := https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_extended_$(HUGO_VERSION)_Linux-64bit.tar.gz
HUGO ?= ./.bin/hugo/$(HUGO_VERSION)/hugo

lint: lint/editorconfig lint/shellcheck lint/yamllint

lint/editorconfig:
	$(EDITORCONFIG_CHECKER)

lint/shellcheck:
	$(SHELLCHECK) $(shell find . -type f -not -path '*/\.bin/*' -name '*.sh')

lint/yamllint:
	$(YAMLLINT) .

test: test/lighthouse

# TODO use lhci from npm/nvm
test/lighthouse:
	lhci autorun

bin/dart-sass-embedded $(DARTSASS):
	mkdir -p $(dir $(DARTSASS))
	$(eval TMP := $(shell mktemp -d))
	wget -q $(DARTSASS_RELEASE) -O $(TMP)/$(@F).tar.gz
	tar -zxvf $(TMP)/$(@F).tar.gz -C $(TMP)
	cp $(TMP)/sass_embedded/$(@F) $(DARTSASS)

bin/hugo $(HUGO):
	mkdir -p $(dir $(HUGO))
	$(eval TMP := $(shell mktemp -d))
	wget -q $(HUGO_RELEASE) -O $(TMP)/$(@F).tar.gz
	tar -zxvf $(TMP)/$(@F).tar.gz -C $(TMP)
	cp $(TMP)/$(@F) $(HUGO)

build: build/hugo

build/hugo: $(HUGO)
	$(HUGO) --minify --cleanDestinationDir --panicOnWarning --templateMetrics --templateMetricsHints

build/docker:
	$(DOCKER) build --pull . \
		--build-arg HUGO_RELEASE=$(HUGO_RELEASE) \
		-t $(IMAGE_WITH_TAG)

serve: serve/hugo

serve/hugo: $(HUGO)
	$(HUGO) server -p 8080 --panicOnWarning

serve/python: build/hugo
	python3 -m http.server -d public 8080

serve/docker:
	$(DOCKER_RUN) -p 8080:8080 $(IMAGE_WITH_TAG)

eject/github:
	$(foreach v, $(filter-out $(EXISTING_VARS) EXISTING_VARS,$(.VARIABLES)), \
	$(info echo "MAKEFILE_$(v)=$($(v))" >> $$GITHUB_ENV))

.PHONY: lint lint/editorconfig lint/shellcheck lint/yamllint test test/lighthouse \
				bin/dart-sass-embedded bin/hugo build build/hugo build/docker \
				serve serve/hugo serve/python serve/docker eject/github
