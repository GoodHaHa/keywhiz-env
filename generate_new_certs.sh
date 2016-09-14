#!/bin/bash

set -u
set -e
set -o pipefail

DRUN="docker run -ti --rm -v $(pwd)/certstrap:/srv -w /srv java8"
CDIR=$(pwd)

echo "--> cleaning any generated certificate."
( cd certstrap;
  sudo rm -rf out/*
)

echo "--> creating CA";
( cd certstrap;
  $DRUN ls
  $DRUN bin/certstrap init --key-bits 4096 --years 1 --common-name "Keywhiz CA";
  $DRUN keytool -import -file 'out/Keywhiz_CA.crt' -alias ca -storetype pkcs12 -storepass ponies -keystore out/Keywhiz_CA.p12;
  sudo cp out/Keywhiz_CA.p12 out/truststore.p12
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
cd certstrap
sudo chown -R webi.webi ${CDIR}/certstrap/out
cat ${CDIR}/certstrap/out/localhost.crt ${CDIR}/certstrap/out/localhost.key >${CDIR}/certstrap/out/localhost.pem
cat ${CDIR}/certstrap/out/Keywhiz_CA.crt ${CDIR}/certstrap/out/Keywhiz_CA.key >${CDIR}/certstrap/out/Keywhiz_CA.pem
sudo chmod 744 out/localhost.key
cd ..

openssl rsa -in ${CDIR}/certstrap/out/client.key -out ${CDIR}/certstrap/out/client.unencrypted.key -passin pass:ponies

echo "# start the wizard, agree to destroy the world, whatever, .."
# echo "cd keywhiz"
# echo "docker run -it --rm -v keywhiz-data:/data -v keywhiz-secrets:/secrets square/keywhiz wizard"

### remove volumes
echo "--> removing old volumes"
docker volume rm keywhiz-data || true
docker volume rm keywhiz-secrets || true

### copy files to the volume
echo "--> copying files to the volume"
DCP="docker run --rm -v keywhiz-secrets:/data -v $(pwd):/srv ubuntu:trusty"
echo "----- srv ----"
$DCP ls /srv/certstrap/out
echo "----- data ----"
$DCP ls /data
echo "----- copying -----"
$DCP cp /srv/certstrap/out/Keywhiz_CA.crl /data/ca-crl.pem
$DCP cp /srv/certstrap/out/Keywhiz_CA.pem /data/ca-bundle.pem
$DCP cp /srv/certstrap/out/localhost.key /data/keywhiz-key.pem
$DCP cp /srv/certstrap/out/localhost.crt /data/keywhiz.pem

echo "start wizard with ./wizard.sh to install certificates"
