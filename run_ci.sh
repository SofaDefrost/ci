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
    # Those paths contain the specific Qt install required by SofaQtQuick
    # & other potential dependencies, installed in /usr/local
    export PATH=/usr/local/Qt-5.12.1/bin:/usr/local/Qt-5.12.1/lib:${PATH}
    export PATH=/usr/local/bin:/usr/local/lib:/usr/local/lib64:${PATH}
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
mkdir -p $PWD/build/unit-tests/reports
cd $PWD/build

cmake .. $(echo $3) -DCMAKE_INSTALL_PREFIX=/builds/$1 -DSOFA_BUILD_TESTS=ON || fail "error" "CMake config failed."
i=0
make -j8 || fail "failure" "Build failed."
make install || fail "failure" "Install failed"

github-notify "pending" "Running tests..."


i=0
j=0
if [ -z "$4" ]; then
    test_dir="bin"
    echo "$test_dir/"
else
    test_dir="$4"
    echo "$test_dir/"
fi
set +e # Undo exit on error

# for file in "$test_dir/"*_test ; do
#     if [ -f $file ]; then
# 	$file || let "i++"
# 	let "j++"
#     fi
# done

bash /builds/ci/unit-tests.sh run $PWD $PWD/..
bash /builds/ci/unit-tests.sh print-summary $PWD $PWD/..

reference=${JOB_NAME/PR/master}

bash /builds/ci/unit-tests.sh run /builds/workspace/$reference/build /builds/workspace/$reference/
bash /builds/ci/unit-tests.sh print-summary /builds/workspace/$reference/build /builds/workspace/$reference/

ntests=`bash /builds/ci/unit-tests.sh count-tests $PWD $PWD/..`
nfailures=`bash /builds/ci/unit-tests.sh count-failures $PWD $PWD/..`
nerrs=`bash /builds/ci/unit-tests.sh count-errors $PWD $PWD/..`
ncrashes=`bash /builds/ci/unit-tests.sh count-crashes $PWD $PWD/..`
nignored=`bash /builds/ci/unit-tests.sh count-disabled $PWD $PWD/..`

master_ntests=`bash /builds/ci/unit-tests.sh count-tests /builds/workspace/$reference/build /builds/workspace/$reference/`
master_nfailures=`bash /builds/ci/unit-tests.sh count-failures /builds/workspace/$reference/build /builds/workspace/$reference/`
master_nerrs=`bash /builds/ci/unit-tests.sh count-errors /builds/workspace/$reference/build /builds/workspace/$reference/`
master_ncrashes=`bash /builds/ci/unit-tests.sh count-crashes /builds/workspace/$reference/build /builds/workspace/$reference/`
master_nignored=`bash /builds/ci/unit-tests.sh count-disabled /builds/workspace/$reference/build /builds/workspace/$reference/`

echo "$reference: $master_ntests $master_nfailures"

status="error"

new_tests=$(( ntests - master_ntests ))
new_failures=$(( nfailures - master_nfailures ))

if [ $new_failures -le "0" ]; then
    status="success"
fi


# github-notify "$status" "$nfailures / $ntests failed. ($nerrs errors, $ncrashes crashes, $nignored ignored)"

nfString="new failures"
if [ $new_failures -le "0" ]; then
    nfString="fixed tests"
fi

ntString="tests added"
if [ $new_tests -lt "0" ]; then
    ntString="tests removed"
fi

github-notify "$status" "$nfailures / $ntests failed. ($new_tests $ntString, $new_failures $nfString)"
