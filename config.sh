# This file is intended to be sourced rather than executed.

# If an environment variable is set, then it will override
# the defaults contained in this file.

setvar() {
  name=$1
  value=$2

  if [ -z "${!name}" ]; then
    eval ${name}=${value}
    export ${name}
  fi
  echo "CONFIG: ${name} = ${!name}"
}

echo "==================================================================================="
setvar RPXC               './bin/rpxc'
# Currently we're not caching enough stuff for the docker image to work properly, so leave
# USE_CACHED_RPXC set to 0 until we figure out what all needs to be cached.
setvar USE_CACHED_RPXC    0
setvar GATEWAY_REPO       https://github.com/mozilla-iot/gateway
setvar GATEWAY_BRANCH     master
setvar TAR_PREFIX         ${GATEWAY_BRANCH}
setvar DEV_BUILD          0
echo "==================================================================================="
