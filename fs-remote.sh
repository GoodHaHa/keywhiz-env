#!/bin/bash

set -e
set -o pipefail
set -u

. ./.env

REMOTE_SERVER="${1}"
CRT_CLIENT_NAME="${2}"
MP="/secret/kwfs"

cd certstrap/out
echo keywhiz-fs --key ${CRT_CLIENT_NAME}.pem --ca ${CA_NAME}.crt https://${REMOTE_SERVER}:4444 ${MP}
keywhiz-fs --key ${CRT_CLIENT_NAME}.pem --ca ${CA_NAME}.crt https://${REMOTE_SERVER}:4444 ${MP}
