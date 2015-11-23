#! /bin/bash

_runPythonTests(){
  cd ~/../tmp/default
  /bin/bash -c "git config --global user.email 'you@example.com'"
  /bin/bash -c "git stash"
  /bin/bash -c "git checkout $APIBRANCH"
  /bin/bash -c "git pull origin $APIBRANCH" 
  python run_tests.py ~/$GOOGLEAPPENGINEPATH/google_appengine src
}

_runPythonTests
exit $?