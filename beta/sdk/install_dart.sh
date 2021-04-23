#!/bin/bash
# Download dart sdk from gcs

function err() {
  echo "Error:" "$@"
  exit 1
}

VERSION="$1"
[[ -z "$VERSION" ]] && err "missing sdk VERSION"

CHANNEL="${2:-stable}"
PLATFORM="${3:-linux}"
ARCH="${4:-x64}"
SDKDEST="${5:=/usr/lib/dart}"

SDK="dartsdk-$PLATFORM-$ARCH-release.zip"
BASEURL="https://storage.googleapis.com/dart-archive/channels"
URL="$BASEURL/$CHANNEL/release/$VERSION/sdk/$SDK"

echo "download sdk: $SDK, VERSION: $VERSION"
echo "$URL"

status=$(curl -O -L "$URL" -w "%{http_code}")
(( status != 200 )) && err "HTTP status code: $status"

# TODO: download *.sha256sum (see https://github.com/docker-library/official-images#security)

unzip "$SDK"
mv dart-sdk "$SDKDEST" && rm "$SDK"
