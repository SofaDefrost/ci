#!/bin/bash

## Updates the sofa build on master
update_sofa() {
    date
    cd $1
    git checkout master
    git pull -r

    make -j4 && make install
}
