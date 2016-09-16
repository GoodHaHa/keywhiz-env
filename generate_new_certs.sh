#!/bin/bash

set -u
set -e
set -o pipefail

echo "--> ${0} started"

CDIR=$(pwd)
DRUN="docker run -ti --rm -v $(pwd)/certstrap:/srv -w /srv java8"
DCP="docker run --rm -v keywhiz-secrets:/secrets -v $(pwd):/srv ubuntu:trusty"

echo "--> cleaning any generated certificate."
( cd certstrap;
  sudo rm -rf out/*
)

(./create_cookie_key.sh)
(./create_content_keystore_password.sh)

echo "--> creating CA";
( cd certstrap;
  $DRUN bin/certstrap init --key-bits 4096 --years 5 --common-name "Keywhiz CA";
  $DRUN keytool -import -file 'out/Keywhiz_CA.crt' -alias ca -storetype pkcs12 -storepass ponies -keystore out/Keywhiz_CA.p12;
  sudo cp out/Keywhiz_CA.p12 out/truststore.p12
)

echo "--> creating client certificates";
( cd certstrap;
  $DRUN bin/certstrap request-cert --common-name client;
  $DRUN bin/certstrap sign --years 1 --CA "Keywhiz CA" client;
)

echo "--> creating server certificate"
( cd certstrap;
  $DRUN bin/certstrap request-cert --domain localhost --ip 127.0.0.1 --organizational-unit server;
  $DRUN bin/certstrap sign --years 1 --CA "Keywhiz CA" localhost;
  $DRUN openssl pkcs12 -export -in out/localhost.crt -inkey out/localhost.key -out out/localhost.p12;
  $DRUN cp out/localhost.p12 out/keystore.p12
)
  sudo chmod 744 ${CDIR}/certstrap/out/localhost.key
  sudo chmod 744 ${CDIR}/certstrap/out/client.key

  openssl rsa -in ${CDIR}/certstrap/out/client.key -out ${CDIR}/certstrap/out/client.unencrypted.key -passin pass:ponies

  cat ${CDIR}/certstrap/out/client.crt ${CDIR}/certstrap/out/client.unencrypted.key >${CDIR}/certstrap/out/client.pem


### remove volumes
echo "--> removing old volumes"
docker volume rm keywhiz-data || true
docker volume rm keywhiz-secrets || true
echo "--> creating new volumes"
docker volume create --name keywhiz-data
docker volume create --name keywhiz-secrets

### copy files to the volume
echo "--> copying files to the volume"
echo "----- srv ----"
$DCP ls /srv/certstrap/out
echo "----- data ----"
ls /srv
echo "----- copying ----"
$DCP cp /srv/certstrap/out/Keywhiz_CA.p12 /secrets/ca-bundle.p12
$DCP cp /srv/certstrap/out/localhost.p12 /secrets/keywhiz-server.p12
$DCP cp /srv/certstrap/out/cookie.key.base64 /secrets/cookie.key.base64
$DCP cp /srv/certstrap/out/content-encryption-keys.jceks /secrets/content-encryption-keys.jceks

echo "--> ${0} finished"
