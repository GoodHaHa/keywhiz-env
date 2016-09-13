#!/bin/bash

set -u
set -e
set -o pipefail

echo "--> cleaning any generated certificate."
( cd certstrap;
  rm -rf out/*
)

echo "--> creating CA";
( cd certstrap;
  bin/certstrap init --key-bits 4096 --years 1 --common-name "Keywhiz CA";
  keytool -import -file 'out/Keywhiz_CA.crt' -alias ca -storetype pkcs12 -storepass ponies -keystore out/Keywhiz_CA.p12;
  cp out/Keywhiz_CA.p12 out/truststore.p12
)


echo "--> creating client certificates";
( cd certstrap;
  bin/certstrap request-cert --common-name client;
  bin/certstrap sign --years 1 --CA "Keywhiz CA" client;
  bin/certstrap request-cert --common-name noSecretsClient;
  bin/certstrap sign --years 1 --CA "Keywhiz CA" noSecretsClient
)

echo "--> creating server certificate"
( cd certstrap;
  bin/certstrap request-cert --domain localhost --ip 127.0.0.1 --organizational-unit server;
  bin/certstrap sign --years 1 --CA "Keywhiz CA" localhost;
  openssl pkcs12 -export -in out/localhost.crt -inkey out/localhost.key -out out/localhost.p12;
  cp out/localhost.p12 out/keystore.p12
)

echo "--> generating pem files"
( cd certstrap;
  cat out/localhost.crt out/localhost.key >out/localhost.pem;
  cat out/Keywhiz_CA.crt out/Keywhiz_CA.key out/Keywhiz_CA.pem;
)

echo "start the wizard, agree to destroy the world, whatever, .."

echo "export CONTAINER='your_container'"
echo "docker cp Keywhiz_CA.crl $CONTAINER:/secrets/ca-crl.pem"
echo "docker cp Keywhiz_CA.pem $CONTAINER:/secrets/ca-bundle.pem"
echo "docker cp localhost.pem $CONTAINER:/secrets/keywhiz-key.pem"

