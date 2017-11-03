#!/bin/bash
set -e

. ./config.sh

mkdir -p $(dirname ${RPXC})

# Build the docker raspberry pi cross compiler, if needed
if [ ${USE_CACHED_RPXC} == 1 -a -f ${RPXC} ]; then
  echo "Using cached version of rpxc"
else
  echo "Creating rpxc"
  set -x
  docker run sdthirlwall/raspberry-pi-cross-compiler > ${RPXC}
  chmod +x ${RPXC}

  sudo ${RPXC} apt update
  sudo ${RPXC} apt upgrade

  ${RPXC} install-raspbian libudev-dev
  ${RPXC} install-debian pkg-config
  ${RPXC} install-debian python
  ${RPXC} install-debian python2.7
fi
