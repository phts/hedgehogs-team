#!/bin/bash

have_unsaved_changes() {
    # Update the index
    git update-index -q --ignore-submodules --refresh

    # unstaged changes in the working tree
    if ! git diff-files --quiet --ignore-submodules --
    then
        return 0
    fi

    # uncommitted changes in the index
    if ! git diff-index --cached --quiet HEAD --ignore-submodules --
    then
        return 0
    fi

    return 1
}

set -x

if ! rspec -c; then
    exit 1
fi

prev_version_tag=`git describe --tags --abbrev=0`
prev_version=`echo $prev_version_tag | sed 's|[^0-9]||g'`
new_version=$(($prev_version+1))
new_version_tag="v$new_version"

filename=hedgehogs-team-$new_version_tag.zip

command -v zip >/dev/null 2>&1
if [ $? -eq 0 ]; then
    mkdir -p ./tmp
    have_unsaved_changes
    had_unsaved_changes=$?
    if [ $had_unsaved_changes -eq 0 ]; then
        echo "Stash unsaved changes"
        git stash
    fi
    zip -j ./tmp/$filename ./my_strategy/*
    if [ $had_unsaved_changes -eq 0 ]; then
        echo "Apply stashed state"
        git stash pop
    fi
else
    echo "WARNING: 'zip' is not found. Please make '$filename' manually."
fi

git tag $new_version_tag
git push --tags origin master
