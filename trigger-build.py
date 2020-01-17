#!/usr/bin/env python3

import argparse
import requests

BASE_URL = \
    'https://api.github.com/repos/mozilla-iot/rpi-image-builder/dispatches'


def main(args):
    """Script entry point."""
    data = {
        'event_type': 'build-image',
        'client_payload': {},
    }

    if args.repo is not None:
        data['client_payload']['gateway_repo'] = args.repo

    if args.branch is not None:
        data['client_payload']['gateway_branch'] = args.branch

    if args.prefix is not None:
        data['client_payload']['tar_prefix'] = args.prefix

    if args.dev is not None and args.dev:
        data['client_payload']['dev_build'] = 1

    response = requests.post(
        BASE_URL,
        headers={
            'Accept': 'application/vnd.github.everest-preview+json',
            'Authorization': 'token {}'.format(args.token),
        },
        json=data,
    )

    if response.status_code == 204:
        print('Build successfully triggered.')
        return True

    print('Failed to trigger build.')
    return False


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Trigger add-on build')
    parser.add_argument('--token', help='GitHub API token', required=True)
    parser.add_argument('--repo', help='Repository to retrieve gateway from')
    parser.add_argument(
        '--branch',
        help='Branch or tag to retrieve from repository'
    )
    parser.add_argument(
        '--prefix',
        help='Prefix to use when generating tarballs'
    )
    parser.add_argument(
        '--dev',
        help='Do a development build (rather than production)',
        action='store_true'
    )
    args = parser.parse_args()

    main(args)
