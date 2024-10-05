MyRC
====
MyRC is a simple rc (for example [NetBSD rc](https://www.netbsd.org/docs/guide/en/chap-rc.html)) clone to be used in user home. This script reads startup scrips from "$HOME/.rc.d" and executes them. Another part of this project is a library that allows to start/stop/restart/reload/status docker containers and classic daemons with ease.

## Usage
To start using this library one needs to add:
```sh
@reboot /bin/sh /usr/local/bin/myrc
```
or the place where myrc is placed. For example you can just clone the repository to some place at your home directory.

## Startup scripts
Each startup script must be able to be run with one argument: command. Supported commands are start, stop, restart, status, reload. To make process easier we provide a small library that allows to implement those commands, but you don't have to use it.


## Used libraries:
https://github.com/fstd/lstd - list library for shell
