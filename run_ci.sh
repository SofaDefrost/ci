#!/bin/bash

fail() {
    github-notify $1 $2
    exit -1    
}

export SCRIPTS_PATH=/builds/ci/scripts

. $SCRIPTS_PATH/utils.sh
. $SCRIPTS_PATH/github.sh

set -o errexit # Exit on error

git config --global user.name 'jackdefrost'
git config --global user.email '<>'

if vm-is-ubuntu; then
    export GITHUB_CONTEXT="Ubuntu-18.04"
elif vm-is-windows; then
    export GITHUB_CONTEXT="Windows-7_MSVC-14.0"
else
    export GITHUB_CONTEXT="MacOS-10.13_Clang-3.5"
fi
export GITHUB_REPOSITORY="$2/$1"
export GITHUB_TARGET_URL=$BUILD_URL
export GITHUB_COMMIT_HASH=$GIT_COMMIT
export GITHUB_DEFROSTBOT_TOKEN=$GIT_TOKEN_JKCONF
export GITHUB_NOTIFY="true"

github-notify "pending" "Building..."

echo $PWD
mkdir -p $PWD/build
cd $PWD/build

cmake .. $(echo $3) -DCMAKE_INSTALL_PREFIX=/builds/$1 -DSOFA_BUILD_TESTS=ON || fail "error" "CMake config failed."
i=0
make -j8 || fail "failure" "Build failed."
make install || fail "failure" "Install failed"

github-notify "pending" "Running tests..."


i=0
j=0
for file in "/builds/$1/bin/"*_test ; do
    if [ -f $file ]; then
	$file || let "i++"
	let "j++"
    fi
done

github-notify "success" "$i/$j tests failed"
