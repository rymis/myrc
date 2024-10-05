all: myrc myrclib.sh
	@echo "DONE"

test: all
	(cd tests; sh run_tests.sh)

