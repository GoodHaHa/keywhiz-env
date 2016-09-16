#!/bin/bash

set -u
set -e
set -o pipefail

echo "--> ${0} starting"

if [[ ! -d certstrap/out ]]; then
    mkdir -vp certstrap/out
fi

COOKIE_KEY=$(head -c32 /dev/urandom | base64)
echo "--> generated cookie key: ${COOKIE_KEY}"
echo "--> writing cookie key to certstrap/out/cookie.keybase64"
echo "${COOKIE_KEY}" >certstrap/out/cookie.key.base64
echo "--> ${0} finished"
