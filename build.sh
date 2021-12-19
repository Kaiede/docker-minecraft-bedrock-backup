#!/bin/sh
#
# Builds the docker backup service

TAG=${1:-dev}
COMMIT=${2:-main}

# Build
#
# QEMU_CPU needs to be set to max when building on Apple Silicon.
# Cuts down on illegal instruction errors.
docker build . \
    --platform linux/amd64 \
    -t kaiede/minecraft-bedrock-backup:${TAG} \
    --build-arg CACHEBUST=$(date +%s) \
    --build-arg COMMIT=${COMMIT}


#    --build-arg QEMU_CPU=max \
