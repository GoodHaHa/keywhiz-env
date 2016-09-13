#!/bin/bash

set -u
set -e
set -o pipefail

DRUN="docker run -ti --rm -v $(pwd)/certstrap:/srv -w /srv java8"

echo "--> cleaning any generated certificate."
( cd certstrap;
  rm -rf out/*
)

echo "--> creating CA";
( cd certstrap;
  $DRUN ls
  $DRUN bin/certstrap init --key-bits 4096 --years 1 --common-name "Keywhiz CA";
  $DRUN keytool -import -file 'out/Keywhiz_CA.crt' -alias ca -storetype pkcs12 -storepass ponies -keystore out/Keywhiz_CA.p12;
  $DRUN cp out/Keywhiz_CA.p12 out/truststore.p12
)


echo "--> creating client certificates";
( cd certstrap;
  $DRUN bin/certstrap request-cert --common-name client;
  $DRUN bin/certstrap sign --years 1 --CA "Keywhiz CA" client;
  $DRUN bin/certstrap request-cert --common-name noSecretsClient;
  $DRUN bin/certstrap sign --years 1 --CA "Keywhiz CA" noSecretsClient
)

echo "--> creating server certificate"
( cd certstrap;
  $DRUN bin/certstrap request-cert --domain localhost --ip 127.0.0.1 --organizational-unit server;
  $DRUN bin/certstrap sign --years 1 --CA "Keywhiz CA" localhost;
  $DRUN openssl pkcs12 -export -in out/localhost.crt -inkey out/localhost.key -out out/localhost.p12;
  $DRUN cp out/localhost.p12 out/keystore.p12
)

echo "--> generating pem files"
( cd certstrap;
  $DRUN cat out/localhost.crt out/localhost.key >out/localhost.pem;
  $DRUN cat out/Keywhiz_CA.crt out/Keywhiz_CA.key >out/Keywhiz_CA.pem;
)

echo "# start the wizard, agree to destroy the world, whatever, .."
echo "cd keywhiz"
echo "docker run -it --rm -v keywhiz-data:/data -v keywhiz-secrets:/secrets square/keywhiz wizard"
echo "#############"
echo "export CONTAINER='your_container'"
echo "docker cp certstrap/out/Keywhiz_CA.crl \$CONTAINER:/secrets/ca-crl.pem"
echo "docker cp certstrap/out/Keywhiz_CA.pem \$CONTAINER:/secrets/ca-bundle.pem"
echo "docker cp certstrap/out/localhost.pem \$CONTAINER:/secrets/keywhiz-key.pem"

