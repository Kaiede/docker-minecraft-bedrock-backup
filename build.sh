#!/bin/bash
#
# Builds the docker backup service

set -euo pipefail

TAG=${1:-dev}
COMMIT=${2:-main}
PUSH=${3:-nopush}

baseimage_arm64="swiftarm/swift:5.5.2-ubuntu-21.04"
baseimage_amd64="swift:5.5.2"

render() {
    sedStr="
    s!%%BASE_IMAGE%%!$image!g;
    "

    sed -r "$sedStr" $1
}

ARCHES=(arm64 amd64)
for ARCH in ${ARCHES[*]}; do
    echo Building: $ARCH
    rm Dockerfile
    image=baseimage_$ARCH
    eval image=\${$image}
    echo Using Image: $image
    render Dockerfile.template > Dockerfile

    docker build . \
        --platform linux/${ARCH} \
        -t kaiede/minecraft-bedrock-backup:${ARCH}-${TAG} \
        --build-arg QEMU_CPU=max \
        --build-arg CACHEBUST=$(date +%s) \
        --build-arg COMMIT=${COMMIT} \
        --build-arg ARCH=${ARCH}

    if [ "$PUSH" == "push" ]; then
        docker push kaiede/minecraft-bedrock-backup:${ARCH}-${TAG}
    fi
done

if [ "$PUSH" == "push" ]; then
    docker manifest rm \
        kaiede/minecraft-bedrock-backup:${TAG}

    docker manifest create \
        kaiede/minecraft-bedrock-backup:${TAG} \
        --amend kaiede/minecraft-bedrock-backup:arm64-${TAG} \
        --amend kaiede/minecraft-bedrock-backup:amd64-${TAG} 

    docker manifest push kaiede/minecraft-bedrock-backup:${TAG}
fi

#docker buildx build . \
#    --platform linux/arm64,linux/amd64 \
#    -t kaiede/minecraft-bedrock-backup:${TAG} \
#    --build-arg QEMU_CPU=max \
#    --build-arg CACHEBUST=$(date +%s) \
#    --build-arg COMMIT=${COMMIT}

#docker build arm64 \
#    --platform linux/arm64 \
#    -t kaiede/minecraft-bedrock-backup:arm64-${TAG} \
#    --build-arg QEMU_CPU=max \
#    --build-arg CACHEBUST=$(date +%s) \
#    --build-arg COMMIT=${COMMIT}

#docker build amd64 \
#    --platform linux/amd64 \
#    -t kaiede/minecraft-bedrock-backup:amd64-${TAG} \
#    --build-arg QEMU_CPU=max \
#    --build-arg CACHEBUST=$(date +%s) \
#    --build-arg COMMIT=${COMMIT}

#docker push kaiede/minecraft-bedrock-backup:arm64-${TAG}
#docker push kaiede/minecraft-bedrock-backup:amd64-${TAG}
#docker manifest create \
#    kaiede/minecraft-bedrock-backup:${TAG} \
#    kaiede/minecraft-bedrock-backup:arm64-${TAG} \
#    kaiede/minecraft-bedrock-backup:amd64-${TAG} 