# Build files needed to create a Raspberry Pi sdcard image

Raspberry Pi SDCard image build for the Web of Things gateway.

Use the `trigger-build.py` script to initiate a build. Modifying
any of the files in this repository and pushing them will also
trigger a build using the defaults specified in `config.sh`.

# `trigger-build.py`

The `trigger-build.py` will trigger a GitHub workflow to start
building an image. You can check the progress by watching
https://github.com/mozilla-iot/rpi-image-builder/actions

The `trigger-build.py` script takes the following arguments:

## `--token TOKEN`

The --token option specifies the GitHub API token, which can
be generated here: https://github.com/settings/tokens

## `--repo REPO`

The `--repo` option specifies the git repository that the
gateway should be cloned from. If this option is not
specified, then the `GATEWAY_REPO` found in `config.sh` will
be used (https://github.com/mozilla-iot/gateway)

## `--branch BRANCH`

The `--branch` specifies the branch name or tag name used to
checkou the gateway code from the git repository. This option
is required.

## `--prefix BASE`

The `--prefix` specifies the prefix to prepend to the
`gateway.tar.gz` file which is generated.

# Overall process to create an SD card

## Build a base image

Follow [these steps](https://github.com/mozilla-iot/wiki/wiki/Creating-the-base-image-file-for-the-Raspberry-Pi)
on the wiki to create a base image.

## Install rpi-image-builder dependencies
* Download/clone rpi-image-builder

```
$ git clone https://github.com/benfrancis/rpi-image-builder.git
```

* Install the Python requests library

```
$ pip3 install requests
```

## Build the gateway

Use the `trigger-build.py` script (documented above) to build the
`gateway.tar.gz` file, e.g. from the rpi-image-builder directory:

```
$ ./trigger-build.py --token <token> --branch master --prefix 0.10.0-pre1
```

This will put these files (with the assigned prefix) onto AWS in a
directory called `tarfiles`. You can use the following command to see
the generated files:

```
aws s3 ls s3://mozillagatewayimages/tarfiles/
```

## Download the tarfiles

You can either use aws commands:
```
aws s3 cp s3://mozillagatewayimages/tarfiles/PREFIX-gateway.tar.gz .
```
or you can use URLs like these:
```
https://s3-us-west-1.amazonaws.com/mozillagatewayimages/tarfiles/PREFIX-gateway.tar.gz
```

## Add the tarfiles to the base image

Run the [`add-gateway.sh`](https://github.com/mozilla-iot/gateway/blob/master/image/add-gateway.sh)
script found in the `image` directory of the
[gateway repository](https://github.com/mozilla-iot/gateway)

```
./add-gateway.sh -g PREFIX-gateway.tar.gz gateway-VERSION-base.img
```
The output image file will have the same name as the base image with `-base`
removed.

## Copy the image to AWS

Use the [`image-to-aws.sh`](https://github.com/mozilla-iot/gateway/blob/master/image/image-to-aws.sh)
script found in the `image` directory of the
[gateway repository](https://github.com/mozilla-iot/gateway)
```
./image-to-aws.sh gateway-VERSION.img
```

You can then access the image using a URL like this:
```
https://s3-us-west-1.amazonaws.com/mozillagatewayimages/images/gateway-VERSION.img.zip
https://s3-us-west-1.amazonaws.com/mozillagatewayimages/images/gateway-VERSION.img.zip.sha256sum
```
