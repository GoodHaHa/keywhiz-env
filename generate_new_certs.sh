#!/bin/bash

set -u
set -e
set -o pipefail

echo "--> ${0} started"

. ./.env
./cleanup.sh

CDIR=$(pwd)
DRUN="docker run -ti --rm -v $(pwd)/certstrap:/srv -w /srv tmp_keywhiz_stuff"
DCP="docker run --rm -v keywhiz-secrets:/secrets -v keywhiz-data:/data -v $(pwd):/srv tmp_keywhiz_stuff"
C="./certstrap-wrapper.sh"

echo "--> generating a few stuff"

keytool \
  -genseckey -alias basekey -keyalg AES -keysize 128 -storepass "${CONTENT_KEYSTORE_PASSWORD}" \
  -keypass "${CONTENT_KEYSTORE_PASSWORD}" -storetype jceks -keystore ${SECRET_DIR}/${CONTENT_KEYSTORE_NAME}

echo "--> creating CA: ${CA_NAME}"
${C} ${CA_PASSWORD} init --key-bits 4096 --years ${CA_YEARS} --common-name \"${CA_NAME}\"
echo "--> creating client certificates";
${C} ${CRT_CLIENT_PASSWORD} request-cert --common-name ${CRT_CLIENT_NAME}
${C} ${CA_PASSWORD} sign --years ${CA_YEARS} --CA "${CA_NAME}" ${CRT_CLIENT_NAME}


echo "--> creating server certificate"
${C} ${CRT_SERVER_PASSWORD} request-cert --domain ${CRT_SERVER_DOMAIN} --ip ${CRT_SERVER_IP} --organizational-unit ${CRT_SERVER_ORGANIZATIONAL_UNIT}
${C} ${CA_PASSWORD} sign --years ${CA_YEARS} --CA \"${CA_NAME}\" ${CRT_SERVER_DOMAIN}

echo "--> building truststore: ca, server, client"
$DRUN keytool -import -file "out/${CA_NAME}.crt" -alias ${CA_ALIAS} -storetype pkcs12 -noprompt -storepass ${TRUSTSTORE_PASSWORD} -keystore out/${TRUSTSTORE_NAME}
$DRUN keytool -import -file "out/${CRT_SERVER_DOMAIN}.crt" -alias ${CRT_SERVER_DOMAIN} -storetype pkcs12 -storepass ${TRUSTSTORE_PASSWORD} -keystore out/${TRUSTSTORE_NAME}
$DRUN keytool -import -file "out/${CRT_CLIENT_NAME}.crt" -alias ${CRT_CLIENT_NAME} -storetype pkcs12 -storepass ${TRUSTSTORE_PASSWORD} -keystore out/${TRUSTSTORE_NAME}

echo "--> building keystore"
$DRUN openssl pkcs12 -export -in out/${CRT_SERVER_DOMAIN}.crt -inkey out/${CRT_SERVER_DOMAIN}.key -out out/${KEYSTORE_NAME} -certfile out/${CA_NAME}.crt -password "pass:${KEYSTORE_PASSWORD}" -passin pass:${CRT_SERVER_PASSWORD};

echo "--> enforcing relaxed key permissions"
sudo chmod 744 ${CDIR}/certstrap/out/${CRT_SERVER_DOMAIN}.key
sudo chmod 744 ${CDIR}/certstrap/out/${CRT_CLIENT_NAME}.key

echo "--> creating client.pem"
openssl rsa -in ${CDIR}/certstrap/out/${CRT_CLIENT_NAME}.key -out ${CDIR}/certstrap/out/${CRT_CLIENT_NAME}.unencrypted.key -passin pass:${CRT_CLIENT_PASSWORD}
cat ${CDIR}/certstrap/out/${CRT_CLIENT_NAME}.crt ${CDIR}/certstrap/out/${CRT_CLIENT_NAME}.unencrypted.key >${CDIR}/certstrap/out/${CRT_CLIENT_NAME}.pem

echo "--> creating new volumes"
docker volume create --name keywhiz-data
docker volume create --name keywhiz-secrets

echo "----- creating an empty file ------"
touch ${CDIR}/aaa

echo "writing down passwords for copying"
echo "${KEYSTORE_PASSWORD}">certstrap/out/keystore_password
echo "${COOKIE_KEY}">certstrap/out/cookie.key.base64
echo "${CONTENT_KEYSTORE_PASSWORD}">certstrap/out/content_keystore_password
echo "${FRONTEND_PASSWORD}">certstrap/out/frontend_password

echo "----- generating docker config --------"
envsubst < config/keywhiz-config.tpl > certstrap/out/keywhiz-docker.yaml

echo "----- copying stuff ----"
$DCP cp -v /srv/aaa /secrets/ca-crl.pem
$DCP cp -v /srv/certstrap/out/${TRUSTSTORE_NAME} ${TRUSTSTORE_PATH}
$DCP cp -v /srv/certstrap/out/${KEYSTORE_NAME} ${KEYSTORE_PATH}
$DCP cp -v /srv/certstrap/out/cookie.key.base64 /secrets/cookie.key.base64
$DCP cp -v /srv/certstrap/out/${CONTENT_KEYSTORE_NAME} /secrets/${CONTENT_KEYSTORE_NAME}
$DCP cp -v /srv/certstrap/out/keywhiz-docker.yaml /data/keywhiz-docker.yaml

echo "---- removing empty file -----"
rm -v ${CDIR}/aaa

./migrate.sh

envsubst <./add-user.exp>run.sh
expect ./run.sh
rm run.sh


echo "--> ${0} finished"

