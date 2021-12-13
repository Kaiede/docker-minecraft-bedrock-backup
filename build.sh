#!/bin/sh
#
# Builds the docker backup service

TAG=${1:-dev}
COMMIT=${2:-main}

docker build . \
    --platform linux/amd64 \
    -t kaiede/minecraft-bedrock-backup:${TAG} \
    --build-arg QEMU_CPU=max \
    --build-arg CACHEBUST=$(date +%s) \
    --build-arg COMMIT=${COMMIT}
