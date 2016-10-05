#!/bin/bash

set -u
set -e
set -o pipefail

client="${1}"

. ./.env

#TODO: use CA name from the env file

echo "--> creating client certificates";
( cd certstrap;
  bin/certstrap request-cert --common-name ${client};
  bin/certstrap sign --years 1 --CA "Keywhiz CA" ${client};
  bin/certstrap request-cert --common-name noSecrets${client};
  bin/certstrap sign --years 1 --CA "Keywhiz CA" noSecrets${client}
)

echo "certstrap/out/${client}.key # for ${client}"
echo "certstrap/out/${client}.crt # for ${client}"

#TODO: stop keywhiz server, get the truststore file, add the key, copy the truststore file back,
#      or find a better idea of doing that.
