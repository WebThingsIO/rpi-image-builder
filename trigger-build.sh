#!/bin/bash
set -e

SCRIPT_NAME=$(basename $0)

usage() {
  echo "Usage: ${SCRIPT_NAME} [option]..."
  echo "  --repo REPOSITORY   Repository to retrieve gateway from"
  echo "  --branch BRANCH     Branch or tag to retrieve from repository"
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

while getopts "hv-:" opt "$@"; do
  case ${opt} in
    -)
      case ${OPTARG} in
        branch)
          BRANCH="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        help)
          usage
          exit 1
          ;;

        prefix)
          PREFIX="${!OPTIND}"
          OPTIND=$(( $OPTIND + 1 ))
          ;;

        repo)
          REPO="${!OPTIND}"
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
  echo "PREFIX     = ${PREFIX}"
fi

if [ -n "${PREFIX}" ]; then
  addEnv TAR_PREFIX "${PREFIX}"
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
    "branch": "master",
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
   https://api.travis-ci.org/repo/mozilla-iot%2Frpi-image-builder/requests
