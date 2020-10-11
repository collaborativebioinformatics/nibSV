NIMBLE_DIR?=${CURDIR}/nimbleDir
export NIMBLE_DIR
# Alternatively, use --nimbleDir:${NIMBLE_DIR} everywhere

all:
	${MAKE} install
quick:
	nim c -r tests/t_kmers.nim
help:
	nimble -h
	nimble tasks
test:
	nimble test --debug # uses "tests/" directory by default
integ-test:
	@echo 'integ-test TBD'
install:
	#nimble install --debug -y
	nimble install -y
pretty:
	find . -name '*.nim' | xargs -L1 nimpretty --indent=4

.PHONY: test
