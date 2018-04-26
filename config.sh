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
setvar GATEWAY_BRANCH     v0.4.0
setvar OPENZWAVE_ZIP      https://codeload.github.com/OpenZWave/open-zwave/zip/ab5fe966fee882bb9e8d78a91db892a60a1863d9
setvar BASE_IMAGE_DIR     https://s3-us-west-1.amazonaws.com/mozillagatewayimages/base
setvar BASE_IMAGE_NAME    gateway-0.4.0-base-desktop.img
# The defaut image name is the base image name minus the -base portion
setvar GATEWAY_IMAGE_NAME "${BASE_IMAGE_NAME/-base/}"
echo "==================================================================================="
