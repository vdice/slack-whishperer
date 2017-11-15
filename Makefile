TEST_ENV_PREFIX := docker run --rm -v ${CURDIR}:/workdir -w /workdir quay.io/deis/shell-dev

SHELLCHECK_CMD := shellcheck scripts/*
BATS_CMD := bats --tap tests

.PHONY: test
test: test-style test-scripts

.PHONY: test
test-style:
	${TEST_ENV_PREFIX} ${SHELLCHECK_CMD}

.PHONY: test
test-scripts:
	${TEST_ENV_PREFIX} ${BATS_CMD}
