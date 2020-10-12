#NIMBLE_DIR?=${CURDIR}/nimbleDir
#export NIMBLE_DIR
# Alternatively, use --nimbleDir:${NIMBLE_DIR} everywhere

build:
	nim c src/nib.nim
all:
	${MAKE} install
quick:
	nim c -r tests/t_kmers.nim
	nim c -r tests/t_util.nim
help:
	nimble -h
	nimble tasks
tests:
	@# much faster than nimble
	${MAKE} -C tests
test:
	nimble test  # uses "tests/" directory by default
integ-test:
	@echo 'integ-test TBD'
install:
	nimble install -y
pretty:
	find src -name '*.nim' | xargs -L1 nimpretty --indent=4 --maxLineLen=1024
	find tests -name '*.nim' | xargs -L1 nimpretty --indent=4 --maxLineLen=1024

.PHONY: test tests
