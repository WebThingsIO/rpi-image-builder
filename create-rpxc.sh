#!/bin/bash

. ./config.sh

mkdir -p $(dirname ${RPXC})

# Build the docker raspberry pi cross compiler, if needed
if [ -f ${RPXC} ]; then
  echo "Using cached version of rpxc"
else
  echo "Creating rpxc"
  docker run sdthirlwall/raspberry-pi-cross-compiler > ${RPXC}
  chmod +x ${RPXC}
fi
