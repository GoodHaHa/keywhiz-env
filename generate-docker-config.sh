#!/bin/bash

set -e
set -u
set -o pipefail

echo "--> ${0} starting"

export KEYWHIZ_CONFIG='certstrap/out/keywhiz-docker.yaml'
export KEYSTORE_PATH='/secrets/keywhiz-server.p12'

export KEYSTORE_PASSWORD=''
#KEYSTORE_PASSWORD=$(cat certstrap/out/content_keystore_password)

export TRUSTSTORE_PATH='/secrets/ca-bundle.p12'
export TRUSTSTORE_PASSWORD='ponies'
export CRL_PATH='/secrets/ca-crl.pem'
export COOKIE_KEY_PATH=$(cat certstrap/out/cookie.key.base64)
export CONTENT_KEYSTORE_PATH='/secrets/content-encryption-key.jceks'
export CONTENT_KEYSTORE_PASSWORD=$(cat certstrap/out/content_keystore_password)

echo "cookie_key_path: ${COOKIE_KEY_PATH}"

echo "--> generating: ${KEYWHIZ_CONFIG}"
envsubst < config/keywhiz-config.tpl > ${KEYWHIZ_CONFIG}

echo "--> ${0} finished"
