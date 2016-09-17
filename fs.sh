#!/bin/bash

set -e
set -u
set -o pipefail

(cd certstrap/out; keywhiz-fs --key client.pem --ca Keywhiz_CA.crt https://127.0.0.1:4444 /secret/kwfs)
