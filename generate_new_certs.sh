#!/bin/bash

set -u
set -e
set -o pipefail

echo "--> ${0} started"

CDIR=$(pwd)
DRUN="docker run -ti --rm -v $(pwd)/certstrap:/srv -w /srv java8"
DCP="docker run --rm -v keywhiz-secrets:/secrets -v keywhiz-data:/data -v $(pwd):/srv ubuntu:trusty"

echo "--> cleaning any generated certificate."
sudo rm -rf ${CDIR}/certstrap/out/*

echo "--> generating a few stuff"
./create_cookie_key.sh
./create_content_keystore_password.sh
./create_keystore_password.sh

echo "--> getting stuff which we have generated"
KEYSTORE_PASSWORD=$(cat ${CDIR}/certstrap/out/keystore_password)

echo "--> creating CA";
( cd certstrap;
  $DRUN bin/certstrap init --key-bits 4096 --years 5 --common-name "Keywhiz CA";
)

echo "--> creating client certificates";
( cd certstrap;
  $DRUN bin/certstrap request-cert --common-name client;
  $DRUN bin/certstrap sign --years 1 --CA "Keywhiz CA" client;
)

echo "--> creating server certificate"
cd certstrap
$DRUN bin/certstrap request-cert --domain localhost --ip 127.0.0.1 --organizational-unit server
$DRUN bin/certstrap sign --years 1 --CA "Keywhiz CA" localhost
cd ..

echo "--> building truststore"
echo "    adding CA to truststore"
$DRUN keytool -import -file 'out/Keywhiz_CA.crt' -alias ca -storetype pkcs12 -storepass ponies -keystore out/truststore.p12
echo "    adding server to truststore"
$DRUN keytool -import -file 'out/localhost.crt' -alias localhost -storetype pkcs12 -storepass ponies -keystore out/truststore.p12
echo "    adding client to truststore"
$DRUN keytool -import -file 'out/client.crt' -alias client -storetype pkcs12 -storepass ponies -keystore out/truststore.p12

echo "--> building keystore"
$DRUN openssl pkcs12 -export -in out/localhost.crt -inkey out/localhost.key -out out/keystore.p12 -certfile out/Keywhiz_CA.crt -password "pass:${KEYSTORE_PASSWORD}";

echo "--> enforcing relaxed key permissions"
sudo chmod 744 ${CDIR}/certstrap/out/localhost.key
sudo chmod 744 ${CDIR}/certstrap/out/client.key

echo "--> creating client.pem"
openssl rsa -in ${CDIR}/certstrap/out/client.key -out ${CDIR}/certstrap/out/client.unencrypted.key -passin pass:ponies
cat ${CDIR}/certstrap/out/client.crt ${CDIR}/certstrap/out/client.unencrypted.key >${CDIR}/certstrap/out/client.pem

echo "--> removing old volumes"
docker volume rm keywhiz-data || true
docker volume rm keywhiz-secrets || true

echo "--> creating new volumes"
docker volume create --name keywhiz-data
docker volume create --name keywhiz-secrets

echo "----- generating docker config --------"
./generate-docker-config.sh

echo "----- creating an empty file ------"
touch ${CDIR}/aaa

echo "----- copying stuff ----"
$DCP cp -v /srv/aaa /secrets/ca-crl.pem
$DCP cp -v /srv/certstrap/out/truststore.p12 /secrets/ca-bundle.p12
$DCP cp -v /srv/certstrap/out/keystore.p12 /secrets/keywhiz-server.p12
$DCP cp -v /srv/certstrap/out/cookie.key.base64 /secrets/cookie.key.base64
$DCP cp -v /srv/certstrap/out/content-encryption-keys.jceks /secrets/content-encryption-key.jceks
$DCP cp -v /srv/certstrap/out/keywhiz-docker.yaml /data/keywhiz-docker.yaml

echo "---- removing empty file -----"
rm -v ${CDIR}/aaa

echo "--> ${0} finished"

