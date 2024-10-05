#!/usr/bin/env python3

import re
import sys
import os
import time

MYRC_ROOT = os.getenv("MYRC_ROOT")
if MYRC_ROOT is None:
    print("MYRC_ROOT is not set")
    sys.exit(0)

MYRC_RC = os.path.join(MYRC_ROOT, "myrc")
if not os.path.exists(MYRC_RC):
    print("myrc is not found")
    sys.exit(0)

watch_string = ""
if os.getenv("MYRC_WATCH"):
    watch_string = f"*/5 * * * *   /bin/sh {MYRC_RC} watch"

_RX = re.compile(r"^@reboot.*myrc")

hasmyrc = False
with open(sys.argv[1], "rt", encoding="utf-8") as f:
    for line in f:
        if _RX.match(line):
            hasmyrc = True

if hasmyrc:
    print("crontab is already initialized")
    sys.exit(0)

print(f"Updating {sys.argv[1]}")
with open(sys.argv[1], "at", encoding="utf-8") as out:
    time.sleep(2)
    out.write(f"""
# Start personal scripts after reboot
@reboot /bin/sh {MYRC_RC}
{watch_string}
""")

