#!/bin/sh
#
# Builds the docker backup service

TAG=${1:-main}

docker build . \
    -t kaiede/minecraft-bedrock-backup \
    --build-arg TAG=${TAG}
