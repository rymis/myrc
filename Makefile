
PREFIX ?= /usr/local

all: myrc myrclib.sh
	@echo "DONE"

test: all
	(cd tests; sh run_tests.sh)

install: myrc myrclib.sh
	install -D -m 755 myrc $(PREFIX)/bin/myrc
	install -D -m 644 myrclib.sh $(PREFIX)/share/myrc/myrclib.sh
	install -D -m 755 update_crontab.py $(PREFIX)/share/myrc/update_crontab.py
