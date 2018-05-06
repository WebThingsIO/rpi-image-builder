#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)

usage() {
  echo "Usage: ${SCRIPT_NAME} [option]..."
  echo "  --repo REPOSITORY   Repository to retrieve gateway from"
  echo "  --branch BRANCH     Branch or tag to retrieve from repository"
  echo "  --base BASE         Name of base image to use"
  echo "  --image IMAGE       Name of the final image file"
  echo "  --brepo REPOSITORY  Repository to retrieve rpi-image-builder from"
  echo "  --bbranch BRANCH    Branch or tag to retrieve rpi-image-builder from repository"
}

ENV=
addEnv() {
  if [ -z "${ENV}" ]; then
    ENV="\"$1\": \"$2\""
  else
    ENV="${ENV}, \"$1\": \"$2\""
  fi
}

VERBOSE=0
BREPO=mozilla-iot/rpi-image-builder
BBRANCH=master

while getopts "hv-:" opt "$@"; do
  case ${opt} in
    -)
      case ${OPTARG} in
        base)
          BASE="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        branch)
          BRANCH="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        image)
          IMAGE_NAME="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        repo)
          REPO="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        brepo)
          BREPO="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        bbranch)
          BBRANCH="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        *)
          echo "Unrecognized option: ${OPTARG}"
          exit 1
          ;;
      esac
      ;;

    h)
      usage
      exit 1
      ;;

    v)
      VERBOSE=1
      ;;

    *)
      echo "Unrecognized option: ${opt}"
      exit 1
      ;;
  esac
done

if [ "${VERBOSE}" == 1 ]; then
  echo "REPO       = ${REPO}"
  echo "BRANCH     = ${BRANCH}"
  echo "BASE       = ${BASE}"
  echo "IMAGE_NAME = ${IMAGE_NAME}"
  echo "BREPO      = ${BREPO}"
  echo "BBRANCH    = ${BBRANCH}"
fi

if [ -n "${REPO}" ]; then
  addEnv GATEWAY_REPO "${REPO}"
fi

if [ -z "${BRANCH}" ]; then
  echo "Must specify a branch/tag to use (using --branch)"
  exit 1
else
  addEnv GATEWAY_BRANCH "${BRANCH}"
fi

if [ -z "${BASE}" ]; then
  echo "Must specify a base image name to use (using --base)"
  exit 1
else
  addEnv BASE_IMAGE_NAME "${BASE}"
fi

if [ -n "${IMAGE_NAME}" ]; then
  addEnv GATEWAY_IMAGE_NAME "${IMAGE_NAME}"
fi

if [ "${VERBOSE}" == 1 ]; then
  echo "ENV = ${ENV}"
fi

# Make sure that the travis command line utility is installed. This is
# required in order to get an authorization token used to access github.
if [[ ! $(type -P travis) ]]; then
  echo "travis utility doesn't seem to be installed."
  echo "See https://github.com/travis-ci/travis.rb#installation for intructions on installing travis."
  exit 1
fi

# See if the user has previsouly created a token. This is normally cached
# in ~/.travis/config.yml
TOKEN=$(travis token --org --no-interactive)
while [ -z "${TOKEN}" ]; do
  # No token - prompt the user
  echo ""
  echo "No travis token - please enter github credentials"
  echo ""
  travis login --org
  TOKEN=$(travis token --org --no-interactive)
done

BODY='{
  "request": {
    "message": "Manually triggered build via api",
    "branch": "'${BBRANCH}'",
    "config": {
      "env": {
        "global": {
          '${ENV}'
        }
      }
    }
  }
}'

curl -s -X POST \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "Travis-API-Version: 3" \
   -H "Authorization: token ${TOKEN}" \
   -d "${BODY}" \
   https://api.travis-ci.org/repo/${BREPO/\//%2F}/requests
