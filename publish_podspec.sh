#!/bin/bash

#Grab pod name
podspecName=$(basename $(find . -name *.podspec) | sed 's/.podspec//g' )
version=$(awk '/\.version/' $podspecName.podspec | awk '/[0-9]\.[0-9]\.[0-9]/' | sed 's/.version//g'  | sed 's/[^0-9/.]//g')

# Pod lint fail
if [ $? != 0 ];then
    exit 1
fi

git add -A
git commit -m 'updated package.'
git push

git tag -m "update podspec" $version
git push --tags

branchname=$(git rev-parse --abbrev-ref HEAD)
sha=$(git rev-parse $branchname)
ref=refs/heads/$version

curl -X POST https://api.github.com/repos/howtank/widget-ios-sdk/git/refs -H "Accept: application/vnd.github+json" -H "Authorization: token $1" -d '{"ref":"'$ref'", "sha":"'$sha'"}'