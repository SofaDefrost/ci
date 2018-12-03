#!/bin/bash
set -o errexit # Exit on error

. /builds/ci/scripts/utils.sh
. /builds/ci/scripts/github.sh

git config --global user.name 'MIMESIS Bot'
git config --global user.email '<>'

github-notify "pending" "Building..."

echo $PWD
mkdir $PWD/build
cd $PWD/build

cmake .. -DCMAKE_PREFIX_PATH=/builds/sofa/build/install
i=0
make -j8 || let "i++"

if [ $i -eq 1 ]
then
    github-notify "failure" "Build failed"
    exit -1
fi

github-notify "success" "Build OK."
github-notify "unit tests" "Running..."

cd bin

i=0
for file in *; do
    ./$file || let "var++"
done

github-notify "success" "$i tests failed"
