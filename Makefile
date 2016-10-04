SHELLCHECK_CMD := shellcheck scripts/*
BATS_CMD := bats --tap tests

TEST_ENV_PREFIX := docker run --rm -v ${CURDIR}:/workdir -w /workdir quay.io/deis/shell-dev
GRADLE_TEST_CMD := docker run --name gradle-test -v ${CURDIR}:/workdir -w /workdir frekele/gradle:3.0-jdk8 ./gradlew test

test-style:
	${SHELLCHECK_CMD}

test-scripts:
	${BATS_CMD}

test: test-style test-scripts

docker-test-style:
	${TEST_ENV_PREFIX} ${SHELLCHECK_CMD}

docker-test-scripts:
	${TEST_ENV_PREFIX} ${BATS_CMD}

docker-test: docker-test-style docker-test-scripts

.PHONY: test-style test-scripts test \
	docker-test-style docker-test-scripts docker-test
