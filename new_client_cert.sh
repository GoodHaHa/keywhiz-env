#!/bin/bash

set -u
set -e
set -o pipefail

client="${1}"
REMOTE_SERVER="${2}"
. ./.env

# but, truststore password is dynamically generated, so we want to override it with the stored password
TRUSTSTORE_PASSWORD=$(cat certstrap/out/TRUSTSTORE_password)

echo "--> creating client certificates";
( cd certstrap;
  bin/certstrap request-cert --common-name ${client};
  sudo bin/certstrap sign --years 1 --CA "${CA_NAME}" ${client};
  bin/certstrap request-cert --common-name noSecrets${client};
  sudo bin/certstrap sign --years 1 --CA "${CA_NAME}" noSecrets${client}
)

echo "certstrap/out/${client}.key # for ${client}"
echo "certstrap/out/${client}.crt # for ${client}"

cat certstrap/out/${client}.crt certstrap/out/${client}.key >certstrap/out/${client}.pem

echo "--> switching to remote host"
docker-machine env ${REMOTE_SERVER} || exit 1
eval $(docker-machine env ${REMOTE_SERVER})

echo "--> getting remote container"
REMOTE_CONTAINER=$(docker ps | grep 'keywhiz' | awk '{print $1}')

echo "--> copying generated key"
docker cp certstrap/out/${client}.crt ${REMOTE_CONTAINER}:/tmp/${client}.crt

echo "--> creating command and copying to container"
echo '#!/bin/bash'>./tmp_cmd.sh
echo >>./tmp_cmd.sh
echo "keytool -import -file \"/tmp/${client}.crt\" -alias ${client} -storetype pkcs12 -storepass ${TRUSTSTORE_PASSWORD} -keystore ${TRUSTSTORE_PATH}" >>./tmp_cmd.sh
chmod +x ./tmp_cmd.sh

docker cp tmp_cmd.sh ${REMOTE_CONTAINER}:/tmp_cmd.sh

echo "--> executing remote command"
docker exec ${REMOTE_CONTAINER} /tmp_cmd.sh

echo "--> cleaning up"
rm -f tmp_cmd.sh

echo "--> done"
