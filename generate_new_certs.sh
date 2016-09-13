#!/bin/bash

set -u
set -e
set -o pipefail

echo "--> cleaning any generated certificate. Press ENTER to continue"
read
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

#TODO: Generate base derivation key
# java -jar server/target/keywhiz-server-*-SNAPSHOT-shaded.jar gen-aes

#TODO: Generate cookie encrypt key
# head -c 32 /dev/urandom | base64 > cookiekey.base64

echo "All kind of keys has been generated:"
echo "certstrap/out/keystore.p12 # for server"
echo "certstrap/out/truststore.p12 # for server"
echo "certstrap/out/client.key # for client"
echo "certstrap/out/client.crt # for client"

