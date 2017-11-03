# Raspberry Pi sdcard image builder

[![Build Status](https://travis-ci.org/mozilla-iot/rpi-image-builder.svg?branch=master)](https://travis-ci.org/mozilla-iot/rpi-image-builder)

Raspberry Pi SDCard image build for the Web of Things gateway.

Use the trigger-build.sh script to initiate a build. Modifying
any of the files in this repository and pushing them will also
trigger a build using the defaults specified in config.sh

# trigger-build.sh

The trigger-build.sh will trigger a travis job to start
building an image. You can check the progress by watching
https://travis-ci.org/mozilla-iot/rpi-image-builder

The trigger-build.sh script takes the following arguments:

## --repo REPO

The --repo option specifies the git repository that the
gateway should be cloned from. If this option is not
specified, then the GATEWAY_REPO found in config.sh will
be used (https://github.com/mozilla-iot/gateway)

## --branch BRANCH

The --branch specifies the branch name or tag name used to
checkou the gateway code from the git repository. This option
is required.

## --base BASE

The --base specifies the name of the base image to retrieve
from AWS. This option is required. You can see available base
images using a command like:
```
aws s3 ls s3://mozillagatewayimages/base/
```

## --image IMAGE_NAME

The --image specifies the name of the final generated image.
If this option is not provided, then the name of the base
image minus the -base portion will be used. Final images can
be found using:
```
aws s3 ls s3://mozillagatewayimages/
```
