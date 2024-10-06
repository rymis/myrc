MyRC
====
MyRC is a simple rc (for example [NetBSD rc](https://www.netbsd.org/docs/guide/en/chap-rc.html)) clone to be used in user home. This script reads startup scrips from "$HOME/.rc.d" and executes them. Another part of this project is a library that allows to start/stop/restart/reload/status docker containers and classic daemons with ease.

## Usage

### Installation
Just clone repository and run `make install`.
```sh
> git clone https://github.com/rymis/myrc.git
> (cd myrc; sudo make install)
```
This will install the script into /usr/local/bin.

Then add to your crontab manually:
```sh
@reboot /bin/sh /usr/local/bin/myrc
```

Or simply:
```sh
> myrc initialize
```

### Writing your startup scripts
Startup scripts should be able to start, stop, restart your service. The easiest way to write them is to use myrclib.sh library. In such case you need to include myrclib.sh at the end of your script and make it compatible.

One can use two techniques to include myrclib.sh. The first one is:
```sh
. "$MYRCLIB"
```

The problem with this is that you need to use `myrc start myservice` instead of `./myservice start` any time you need to start it. The other way is
```sh
R=$(cd $(dirname "$0"); pwd)
. "$R/.myrclib.sh"
```

Then you have three options. Firstly, you can implement start, stop, and status functions manually in such way:
```sh
start() {
    myservice start
}
stop() {
    myservice stop
}
status() {
    myservice status
}
. "$MYRCLIB"
```

Your service now supports all the commands. Also you can add reload and restart targets. This works for lots of services and allows to use them with ease.

The second option is to use start-stop-daemon to run programs that don't support daemonization. For example:
```sh
MYRC_EXEC=python3
MYRC_ARGS="-m http.server -D /var/wwwroot"
. "$MYRCLIB"
```

And that's it. This starts python http.server and controls it automatically.

And the third (and for now the last) option is to use docker images as services. You can do it like this:
```sh
MYRC_DOCKER="-p 8000:80 -v /tmp:/www busybox httpd -h /www -f"
. "$MYRCLIB"
```

This command starts something like `docker run --detach --rm --label myrclabel=httpd -p 8000:80 -v /tmp:/www busybox httpd -h /www -f` and allows to restart and control the container.

### Watch mode
If you start `myrc watch` (or the command for one service) myrc checks the status and if service failed restarts it. So, you can add `myrc watch` to crontab and run it once a while to restart failed services.

