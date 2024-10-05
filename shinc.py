#!/usr/bin/env python3

import os
import re
import sys


_RE_INC = re.compile(r"^\. ([a-zA-Z0-9._-]+)")
def process_file(fnm):
    dir = os.path.dirname(fnm)
    with open(fnm, "rt", encoding="utf-8") as f:
        for line in f:
            m = _RE_INC.match(line)
            if m:
                process_file(m.group(1))
            else:
                sys.stdout.write(line)


def main():
    process_file(sys.argv[1])


if __name__ == '__main__':
    main()
