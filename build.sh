#!/bin/sh
#
# Builds the docker backup service

TAG=${1:-dev}
COMMIT=${1:-main}

docker build . \
    -t kaiede/minecraft-bedrock-backup:${TAG} \
    --build-arg CACHEBUST=$(date +%s) \
    --build-arg COMMIT=${COMMIT}
