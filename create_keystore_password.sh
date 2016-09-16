#!/bin/bash

set -u
set -e
set -o pipefail

echo "--> ${0} starting"

KEYSTORE_PASSWORD=$(head -c16 /dev/urandom | xxd -p)
KEYSTORE_PASSWORD_PATH='certstrap/out/keystore_password'

echo "--> generating keystore password"
echo "${KEYSTORE_PASSWORD}" > "${KEYSTORE_PASSWORD_PATH}"

echo "--> ${0} finished"
