#!/bin/bash
set -e

. ./config.sh

mkdir -p $(dirname ${RPXC})

# Build the docker raspberry pi cross compiler, if needed
if [ ${USE_CACHED_RPXC} == 1 -a -f ${RPXC} ]; then
  echo "Using cached version of rpxc"
else
  echo "Creating rpxc"
  docker run dhylands/raspberry-pi-cross-compiler-stretch > ${RPXC}
  chmod +x ${RPXC}
fi
