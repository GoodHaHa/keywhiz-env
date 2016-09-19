#!/bin/bash

set -e
set -o pipefail

. ./.env

MP="/secret/kwfs"
if [[ ! -z ${1} ]]; then
  echo "mountpoint is now $1"
  MP="$1"
else
  echo "using default mountpoint: /secret/kwfs"
fi

cd certstrap/out
echo keywhiz-fs --key ${CRT_CLIENT_NAME}.pem --ca ${CA_NAME}.crt https://127.0.0.1:4444 ${MP}
keywhiz-fs --key ${CRT_CLIENT_NAME}.pem --ca ${CA_NAME}.crt https://127.0.0.1:4444 ${MP}
