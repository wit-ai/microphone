#!/usr/bin/env bash

if ! which jq; then
  echo 'you need jq -- brew install jq or http://stedolan.github.io/jq/'
  exit 1
fi

set -x -e

VER=$(cat bower.json | jq --raw-output '.version')
DIR=release/microphone-$VER
TAR=microphone-$VER.tar.gz

# build and move to release directory
grunt build
mkdir -p $DIR
cp -r dist/* $DIR

# modify assets
cd $DIR
echo "/* microphone.js $VER */" | cat - microphone.js > microphone.min.js
echo "/* microphone.css $VER */" | cat - microphone.css > microphone.min.css
rm microphone.{js,css}
rm index.html
cd -

# zip it
cd $(dirname $DIR)
tar czvf $TAR $(basename $DIR)
cd -

# push to github
set +x
echo -n "github username: "
read GH_USER
echo -n "github password: "
read -s GH_PW
echo
# create release
RELEASE_ID=$(curl -XPOST https://api.github.com/repos/wit-ai/microphone/releases -d '{
  "tag_name": "'$VER'",
  "name": "'$VER'"
}' -s -u "$GH_USER:$GH_PW" | jq --raw-output '.id')

# upload archive
TAR_PATH=$(dirname $DIR)/$TAR
echo "uploading $TAR_PATH to https://api.github.com/repos/wit-ai/microphone/releases/$RELEASE_ID/assets?name=$TAR"
curl -XPOST "https://uploads.github.com/repos/wit-ai/microphone/releases/$RELEASE_ID/assets?name=$TAR" \
  -H 'Content-Type: application/octet-stream' -s --data-binary "@$TAR_PATH" -u "$GH_USER:$GH_PW"
set -x

# clean
rm -rf $DIR
