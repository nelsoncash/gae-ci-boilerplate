#!/bin/bash

for i in "$@"
do
case $i in
    -b=*|--branch=*)
    BRANCH="${i#*=}"
    shift # past argument=value
    ;;
    -r=*|--repo=*)
    REPO="${i#*=}"
    shift # past argument=value
    ;;
esac
done
echo "${BRANCH}"
echo "${REPO}"


_init(){
  cd $WATCHER
  python main.py --repo_path="${REPO}" --run_path="../usr/bin/run-all-tests" --interval=60 --branch="${BRANCH}"
}
_init
