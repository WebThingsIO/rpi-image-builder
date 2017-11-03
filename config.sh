# This file is intended to be sourced rather than executed.

# If an environment variable is set, then it will override
# the defaults contained in this file.

setvar() {
  name=$1
  value=$2

  if [ -z "${!name}" ]; then
    eval ${name}=${value}
  fi
  echo "CONFIG: ${name} = ${!name}"
}

echo "==================================================================================="
setvar RPXC               './bin/rpxc'
# Currently we're not caching enough stuff for the docker image to work properly, so leave
# USE_CACHED_RPXC set to 0 until we figure out what all needs to be cached.
setvar USE_CACHED_RPXC    0
setvar USE_CACHED_BASE    1
setvar GATEWAY_REPO       https://github.com/mozilla-iot/gateway
setvar GATEWAY_BRANCH     0.2.2
setvar OPENZWAVE_ZIP      https://github.com/OpenZWave/open-zwave/archive/master.zip
setvar BASE_IMAGE_DIR     https://s3-us-west-1.amazonaws.com/mozillagatewayimages/base
setvar BASE_IMAGE_NAME    gateway-base-0.2.2.img
# The defaut image name is the base image name minus the -base portion
setvar GATEWAY_IMAGE_NAME "${BASE_IMAGE_NAME/-base/}"
echo "==================================================================================="
