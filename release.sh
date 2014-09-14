#!/bin/bash

set -ex

mkdir -p ./tmp

prev_version_tag=`git describe --tags --abbrev=0`
prev_version=`echo $prev_version_tag | cut -c 2-10`
new_version=$(($prev_version+1))
new_version_tag="v$new_version"

filename=hedgehogs-team-$new_version_tag.zip

command -v zip >/dev/null 2>&1
if [ $? -eq 0 ]; then
    zip ./tmp/$filename my_strategy.rb utils.rb
else
    echo "WARNING: 'zip' is not found. Please make '$filename' manually."
fi

git tag $new_version_tag
git push --tags origin master
