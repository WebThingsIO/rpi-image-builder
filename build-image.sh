#!/bin/bash
set -e

. ./config.sh

echo "Cloning branch ${GATEWAY_BRANCH} of ${GATEWAY_REPO}"

set -x

# Do a shallow clone of the gateway repository.
git clone --depth 1 --branch ${GATEWAY_BRANCH} ${GATEWAY_REPO}

# Grab the latest open-zwave and unpack it
mkdir -p OpenZWave
rm -rf OpenZWave/open-zwave

rm -rf master.zip open-zwave-master
wget ${OPENZWAVE_ZIP}

unzip $(basename ${OPENZWAVE_ZIP})
mv open-zwave-master OpenZWave/open-zwave

# Go build the gateway dependencies
${RPXC} bash -c ./gateway/image/build-gateway.sh

# Grab the base image, if needed

BASE_IMAGE_ZIP="${BASE_IMAGE_NAME}.zip"

mkdir -p base
rm -f "base/${BASE_IMAGE_ZIP}.sha256sum"
wget --directory-prefix=base "${BASE_IMAGE_DIR}/${BASE_IMAGE_ZIP}.sha256sum"
if [ ${USE_CACHED_BASE} == 1 ]; then
  if [ -f "base/${BASE_IMAGE_ZIP}" ]; then
    echo "Checking cached base image"
    (cd base; sha256sum --check "${BASE_IMAGE_ZIP}.sha256sum" || rm -f "${BASE_IMAGE_ZIP}")
    echo "Checksum verified - using cached base"
  else
    echo "No cached copy - downloading base"
  fi
fi
if [ ! -f "base/${BASE_IMAGE_ZIP}" ]; then
  wget --directory-prefix=base "${BASE_IMAGE_DIR}/${BASE_IMAGE_ZIP}"
fi
(cd base; sha256sum --check "${BASE_IMAGE_ZIP}.sha256sum")

# Merge in the gateway code
./gateway/image/add-gateway.sh -o openzwave.tar.gz -g gateway.tar.gz "base/${BASE_IMAGE_ZIP}"
mkdir -p image
FINAL_IMAGE_NAME="base/${BASE_IMAGE_NAME}-final.img"
mv "${FINAL_IMAGE_NAME}" "${GATEWAY_IMAGE_NAME}"
zip "image/${GATEWAY_IMAGE_NAME}.zip" "${GATEWAY_IMAGE_NAME}"
(cd image; sha256sum "${GATEWAY_IMAGE_NAME}.zip" > "${GATEWAY_IMAGE_NAME}.zip.sha256sum")

echo "Image     download link is: https://s3-us-west-1.amazonaws.com/mozillagatewayimages/images/${GATEWAY_IMAGE_NAME}.zip"
echo "sha256sum download link is: https://s3-us-west-1.amazonaws.com/mozillagatewayimages/images/${GATEWAY_IMAGE_NAME}.zip.sha256sum"
