#!/bin/bash

set -e
set -u
set -o pipefail

echo "--> ${0} starting"
CONTENT_KEYSTORE_PASSWORD=$(head -c16 /dev/urandom | xxd -p)
CONTENT_KEYSTORE_PATH="certstrap/out/content-encryption-keys.jceks"

if [[ -f "${CONTENT_KEYSTORE_PATH}" ]]; then
  echo "--> cleaning up ${CONTENT_KEYSTORE_PATH}"
  rm -f "${CONTENT_KEYSTORE_PATH}"
fi

echo "--> generating ${CONTENT_KEYSTORE_PATH}"
keytool \
  -genseckey -alias basekey -keyalg AES -keysize 128 -storepass "$CONTENT_KEYSTORE_PASSWORD" \
  -keypass "$CONTENT_KEYSTORE_PASSWORD" -storetype jceks -keystore $CONTENT_KEYSTORE_PATH

echo "--> ${0} finished"
