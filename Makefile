TEST_ENV_PREFIX := docker run --rm -v ${CURDIR}:/workdir -w /workdir

DOCKER_REGISTRY   ?= ghcr.io
DOCKER_ORG        ?= vdice
DOCKER_TAG        ?= latest
DOCKER_BUILD_OPTS ?= --load

default: build test

.PHONY: test
test: test-style test-scripts

.PHONY: test-style
test-style:
	${TEST_ENV_PREFIX} koalaman/shellcheck:v0.8.0 scripts/*

.PHONY: test-scripts
test-scripts:
	${TEST_ENV_PREFIX} bats/bats:1.7.0 --tap tests

.PHONY: build
build:
	docker build \
		-t ${DOCKER_REGISTRY}/${DOCKER_ORG}/slack-whishperer:${DOCKER_TAG} \
		${DOCKER_BUILD_OPTS} .

.PHONY: push
push:
	docker push \
		${DOCKER_REGISTRY}/${DOCKER_ORG}/slack-whishperer:${DOCKER_TAG}