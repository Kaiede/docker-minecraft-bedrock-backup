#!/bin/sh
#
# Renders the final Dockerfiles for building

set -euo pipefail

renderPlatforms=${1:-all}

baseimage_arm64="swiftarm/swift:5.5.2-ubuntu-21.04"
baseimage_amd64="swift:5.5.2"

function render {
    sedStr="
    s!%%BASE_IMAGE%%!$image!g;
    "

    sed -r "$sedStr" $1
}

if [ "$renderPlatforms" == "all" ]; then
    arches=(arm64 amd64)
else
    arches=($renderPlatforms)
fi

for arch in ${arches[*]}; do
    echo Creating "$arch.dockerfile"
    if [ -e $arch.dockerfile ]; then
        rm $arch.dockerfile
    fi

    image=baseimage_$arch
    eval image=\${$image}
    echo Using Base Image: $image
    echo Rendering...
    render Template.dockerfile > $arch.dockerfile
done