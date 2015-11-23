#! /bin/bash

_runPythonWatcherAsDaemon(){
  setsid /usr/bin/run-watcher -b=$APIBRANCH -r=../tmp/default > /var/log/api_watcher.log < /var/log/api_watcher.log &
}

_init(){
  _runPythonWatcherAsDaemon
}

_init