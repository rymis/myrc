#!/bin/sh
# MyRC script library
# This library contains simple functions to make writing rc scripts faster.
#
# The code can only be used as an include in RC scripts
# In the end of your script add ". myrclib.sh" to use these functions

export MYRC_SERVICE="$(basename "$0")"
export MYRC_PIDFILE="${MYRC_PATH}/.pid-${MYRC_SERVICE}"

## Get status of docker container by label
docker_status() {
    docker container list -f "label=myrclabel=$MYRC_SERVICE" | awk 'BEGIN {first=1;} { if (!first) print $1; first = 0; }' | grep RUNNING
}

## Get status of docker container by label
docker_stop() {
    docker container ps --filter "label=myrclabel=$MYRC_SERVICE" | awk '/^[a-f0-9]+ / { print $1; }' | while read MYRC_docker_id; do
        echo "Stopping: $MYRC_docker_id..."
        docker container stop -t 5 $MYRC_docker_id
    done
}

## Start docker container using arguments sent to this command
docker_start() {
    echo "Starting: docker run --detach --rm --label myrclabel=$MYRC_SERVICE $@"
    docker run --detach --rm --label myrclabel="$MYRC_SERVICE" "$@"
}

## Start daemon using start-stop-daemon tool.
## Arguments:
##   executable    executable to run
##   args          optional arguments to send to the process
exec_start() {
    if [ "x$2" = "x" ]; then
        start-stop-daemon --start --pidfile "$MYRC_PIDFILE" --background --make-pidfile --exec "$(which "$1")"
    else
        start-stop-daemon --start --pidfile "$MYRC_PIDFILE" --background --make-pidfile --exec "$(which "$1")" -- $2
    fi
}

## Stop daemon that uses correct PID file ($MYRC_PIDFILE).
exec_stop() {
    start-stop-daemon --stop --pidfile "$MYRC_PIDFILE" --oknodo
}

## Check process status using PIDFILE.
exec_status() {
    start-stop-daemon --status --pidfile "$MYRC_PIDFILE"
    if [ $? -eq 0 ]; then
        echo "$MYRC_SERVICE: OK"
        exit 0
    else
        echo "$MYRC_SERVICE: FAILED"
        exit 1
    fi
}

run_start() {
    if has_func start; then
        start
    elif [ "x$MYRC_DOCKER" != "x" ]; then
        docker_start $MYRC_DOCKER
    elif [ "x$MYRC_EXEC" != "x" ]; then
        exec_start "$MYRC_EXEC" "$MYRC_ARGS"
    else
        echo "ERROR: function start is not defined" 1>&2
        exit 1
    fi
}

run_stop() {
    if has_func stop; then
        stop
    elif [ "x$MYRC_DOCKER" != "x" ]; then
        docker_stop
    elif [ "x$MYRC_EXEC" != "x" ]; then
        exec_stop
    else
        echo "ERROR: function start is not defined" 1>&2
        exit 1
    fi
}

run_restart() {
    if has_func stop; then
        restart
    else
        log "Stopping $MYRC_SERVICE"
        run_stop
        sleep 1
        log "Starting $MYRC_SERVICE"
        run_start
    fi
}

run_reload() {
    if has_func stop; then
        reload
    else
        run_restart
    fi
}

run_status() {
    if has_func status; then
        status
    elif [ "x$MYRC_DOCKER" != "x" ]; then
        docker_status
    elif [ "x$MYRC_EXEC" != "x" ]; then
        exec_status
    else
        die "Status function is not defined"
    fi
}

run_watch() {
    # First run status:
    if run_status; then
        echo "Status OK, nothing to do"
    else
        echo "Failed service. Trying to restart"
        # Running stop to be sure that service is stopped
        run_stop
        sleep 2
        run_start
    fi
}

has_func() {
    cat "$MYRC_SCRIPT" | grep -e "^$1\\(\\)" > /dev/null
}

has_arg() {
    MYRC_has_arg_res=0
    MYRC_has_arg_arg="$1"
    while [ "x$2" = "x" ]; do
        if [ "x$2" = "x$MYRC_has_arg_arg" ]; then
            MYRC_has_arg_res=1
            break
        fi
        shift
    done
    echo "$MYRC_has_arg_res"
}

# Main function:
main() {
    case "$1" in
        start)
            run_start
            ;;
        stop)
            run_stop
            ;;
        restart)
            run_restart
            ;;
        reload)
            run_reload
            ;;
        status)
            run_status
            ;;
        watch)
            run_watch
            ;;
        *)
            echo "ERROR: unknown mode $1" 1>&2
            exit 1
    esac
}

main "$1"
