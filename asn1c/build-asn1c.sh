#!/usr/bin/env bash

# usage: ./build.sh [password] [tag]
# example: ./build.sh mySuperPassword v1.5.1

# defaults
PASSWORD="${1:-password}"
TAG="${2:-v1.5.1}"

IMAGE_NAME="asn1c:${TAG}"
TAR_FILE="asn1c-${TAG}.tar"

echo "Build asn1c-image with password '$PASSWORD' and tag '$TAG'"
export USER_PASSWORD="$PASSWORD"

docker build \
  --no-cache \
  --progress=plain \
  -t "$IMAGE_NAME" \
  --secret id=user_password,env=USER_PASSWORD \
  .

docker save -o "$TAR_FILE" "$IMAGE_NAME"
xz -9e --extreme -T0 "$TAR_FILE"
