VERSION = `git rev-parse --short HEAD`
PROGRAM=gin bar

all: all test
	@echo Run all scripts ...

lint:
	yarn lint

test:
	forge test