set -e

function test {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        curl -H 'Content-Type: application/json' -X POST -d '{"text":"tests fail", "icon_emoji": ":ghost:", "username": "$SLACKUSERNAME"}' $SLACKWEBHOOKURL
        echo "error with $1" >&2
    fi
    return $status
}


_runAllTests(){
  test /usr/bin/python-tests
}

_notifySlack(){
  curl -H "Content-Type: application/json" -X POST -d '{"text":"tests pass", "icon_emoji": ":ghost:", "username": "$SLACKUSERNAME"}' $SLACKWEBHOOKURL
}

_runAllTests
_notifySlack

exit $?