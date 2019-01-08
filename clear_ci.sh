#!/bin/bash

export SCRIPTS_PATH=/builds/ci/scripts
. $SCRIPTS_PATH/utils.sh
. $SCRIPTS_PATH/github.sh

set -o errexit # Exit on error

git config --global user.name 'jackdefrost'
git config --global user.email '<>'

export GITHUB_REPOSITORY="SofaDefrost/SofaQtQuick"
export GITHUB_TARGET_URL=$BUILD_URL
export GITHUB_COMMIT_HASH=$GIT_COMMIT
export GITHUB_DEFROSTBOT_TOKEN=$GIT_TOKEN_JKCONF
export GITHUB_NOTIFY="true"


export GITHUB_CONTEXT="Ubuntu-18.04"
github-notify "pending" "Build queued."

# export GITHUB_CONTEXT="Windows-7_MSVC-14.0"
# github-notify "pending" "Build queued."

#export GITHUB_CONTEXT="MacOS-10.13_Clang-3.5"
#github-notify "pending" "Build queued."
