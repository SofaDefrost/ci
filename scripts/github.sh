#!/bin/bash
set -o errexit # Exit on error

. /builds/ci/scripts/utils.sh

github-notify() {
    local state="$1"
    local message="$2"

    local options="$-"
    local notify="not sent"
    local response=""

    set +x # Private stuff here: echo disabled
    if [[ "$GITHUB_NOTIFY" == "true" ]] &&
       [ -n "$GITHUB_CONTEXT" ] &&
       [ -n "$GITHUB_TARGET_URL" ] &&
       [ -n "$GITHUB_REPOSITORY" ] &&
       [ -n "$GITHUB_COMMIT_HASH" ] &&
       [ -n "$GITHUB_MIMESISBOT_TOKEN" ]; then
        local request="{
            \"context\": \"$GITHUB_CONTEXT\",
            \"state\": \"$state\",
            \"description\": \"$message\",
            \"target_url\": \"$GITHUB_TARGET_URL\"
        }"

        response="$(curl --silent --header "Authorization: token $GITHUB_MIMESISBOT_TOKEN" --data "$request" "https://api.github.com/repos/$GITHUB_REPOSITORY/statuses/$GITHUB_COMMIT_HASH")"
        if [ -n "$response" ]; then
            notify="sent"
        fi
    fi
    set -$options

    echo "Notify GitHub ($notify): [$state] $GITHUB_CONTEXT - $message"
    # if [ -n "$response" ]; then
    #     echo "GitHub reponse: $response"
    # fi
}
