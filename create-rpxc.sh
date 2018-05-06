#!/bin/bash
set -e

. ./config.sh

mkdir -p $(dirname ${RPXC})
mkdir -p $(dirname ${DOCKER_CACHE})

rm -rf $(basename ${GATEWAY_REPO})
git clone --depth 1 --branch ${GATEWAY_BRANCH} ${GATEWAY_REPO}

BUILDER=gateway/image/builder
BUILDER_CACHE=docker/builder

# Build the docker raspberry pi cross compiler, if needed
if [ ${USE_CACHED_RPXC} == 1 ] && [ -f ${DOCKER_CACHE} ] && [ -z "`diff -r ${BUILDER} ${BUILDER_CACHE}`" ]; then
  echo "Using cached version of rpxc"
  gzip -dc ${DOCKER_CACHE} | docker load
else
  echo "Creating rpxc"
  set -x
  docker run sdthirlwall/raspberry-pi-cross-compiler > ${RPXC}
  chmod +x ${RPXC}
  docker build -t ${BUILDER_IMAGE} ${BUILDER}

  # Store cache
  docker save ${BUILDER_IMAGE} | gzip > ${DOCKER_CACHE}
  rm -rf ${BUILDER_CACHE}
  cp -r ${BUILDER} ${BUILDER_CACHE}
fi
