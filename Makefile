SHELL=/bin/bash
LINK_FLAGS = --link-flags "-static"
# BUILD_FLAGS = --release

.PHONY : static
static: src/bin/fburl.cr
	crystal build ${BUILD_FLAGS} $^ -o fburl ${LINK_FLAGS}

.PHONY : test
test: check_version_mismatch spec

.PHONY : spec
spec:
	crystal spec -v --fail-fast

.PHONY : check_version_mismatch
check_version_mismatch: shard.yml README.cr.md
	diff -w -c <(grep version: README.cr.md) <(grep ^version: shard.yml)
