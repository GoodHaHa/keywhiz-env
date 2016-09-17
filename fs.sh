#!/bin/bash

set -e
set -u
set -o pipefail

. ./.env

cd certstrap/out
echo keywhiz-fs --key ${CRT_CLIENT_NAME}.pem --ca ${CA_NAME}.crt https://127.0.0.1:4444 /secret/kwfs
keywhiz-fs --key ${CRT_CLIENT_NAME}.pem --ca ${CA_NAME}.crt https://127.0.0.1:4444 /secret/kwfs
