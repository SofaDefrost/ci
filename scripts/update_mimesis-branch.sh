#!/bin/sh

update_mimesis-branch() {
    # ALL CARIBOU BRANCHES
    git branch -r | tee mimesis_branches.txt > /dev/null

    #WHITELISTED BRANCHES TO MERGE
    grep -vxFf $SCRIPTS_PATH/blacklist_branches.txt mimesis_branches.txt | tee whitelist.txt > /dev/null

    git checkout mimesis

    echo "list of branches to merge:"
    cat whitelist.txt

    # merging all the team's branches in mimesis
    while read branch
    do
	echo "merging $branch..."
	git merge $branch
    done < whitelist.txt

    # merge master in mimesis
    git merge master

    # push to the remote
    git push -u origin mimesis

    # get back on master (important for other scripts assuming they're on master...)
    git checkout master
}
