#!/bin/sh

# Run tests and check results

ROOT="$(cd $(dirname "$0"); pwd)"
export ROOT
export SLEEP_BETWEEN=0

export MYRC_DOCKER_EXECUTABLE="$ROOT/docker.sh"

RES=0

run_one_test() {
    export TEST="$1"
    MYRC_PATH="${ROOT}/$TEST/myrc"
    export MYRC_PATH
    shift

    TMPLOG="${ROOT}/$TEST/exec.log"

    rm -f "$TMPLOG"
    touch "$TMPLOG"
    while [ "x$1" != "x" ]; do
        sh ../myrc "$1" | sed 's/^[0-9T:\+-]*\s*//g;s/[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/DOCKERID/g' >> "$TMPLOG"
        echo "STATUS: $?" >> "$TMPLOG"
        shift
        sleep $SLEEP_BETWEEN
    done

    if diff "$TMPLOG" "${ROOT}/$TEST/etalon.log"; then
        echo "$TEST: success"
        rm "$TMPLOG"
    else
        echo "$TEST: failed"
        RES=$(expr $RES + 1)
    fi
}

run_one_test simple_test start status stop
export SLEEP_BETWEEN=2
run_one_test exec start status stop
run_one_test docker start status stop
run_one_test watch start watch status stop

exit $RES
