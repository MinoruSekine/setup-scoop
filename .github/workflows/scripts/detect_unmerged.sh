#!/bin/sh
GIT_LOG=$(git log --oneline --no-merges "$1..$2")
GIT_LOG_RESULT=$?

if [ $GIT_LOG_RESULT -ne 0 ]; then
    echo "::error::git log failed."
    exit 1
fi

if [ -n "$GIT_LOG" ]; then
    COUNT=$(printf '%s\n' "$GIT_LOG" | grep -c '^')
    echo "::error::${COUNT} commit(s) in $2 have not been merged to $1."
    echo "$GIT_LOG"
    exit 1
else
    echo "::notice::All commits in $2 have been merged to $1."
    exit 0
fi
