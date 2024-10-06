#!/bin/sh

CMD="$1"

if [ "x$CMD" = "xrun" ]; then
    while [ "x$1" != "xbusybox" -a "x$1" != "x" ]; do
        shift
    done
    shift

    eval sh -c "'/usr/bin/env MYRC_TEST_DOCKER=yes $@'"
elif [ "x$CMD" = "xcontainer" ]; then
    case "$2" in
        ls)
            echo "CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES"
            ps aux | grep MYRC_TEST_DOCKER=yes | grep -v grep | awk '{print $2, " busybox sleep 1"}'
            ;;
        stop)
            echo "Stopping DOCKERID..."
            ps axu | grep MYRC_TEST_DOCKER=yes | grep -v grep | awk '{print "kill ", $2}' | sh
            ;;
    esac
fi

