#!/bin/bash

set -xueo pipefail

REMOTE_HOST="${1}"
SECRETS_BACKUP_DIR="$(pwd)/remote_backup_secrets"
DATA_BACKUP_DIR="$(pwd)/remote_backup_data"

echo "--> getting into the docker host"
docker-machine env ${REMOTE_HOST} # will fail if not working
eval $(docker-machine env ${REMOTE_HOST})

echo "--> querying remote container"
REMOTE_CONTAINER=$(docker ps | grep keywhiz | awk '{print $1}')

echo "--> preparing backup directory"
if [[ ! -d ${DATA_BACKUP_DIR} ]]; then
  mkdir -pv "${DATA_BACKUP_DIR}"
else
  rm -rvf "${DATA_BACKUP_DIR}/*"
fi
if [[ ! -d "${SECRETS_BACKUP_DIR}" ]]; then
  mkdir -pv "${SECRETS_BACKUP_DIR}"
  rm -rvf "${SECRETS_BACKUP_DIR}/*"
fi

echo "backing up data"

docker exec ${REMOTE_CONTAINER} ls /data | while read F; do
  echo "$F"
  docker cp ${REMOTE_CONTAINER}:/data/${F} ${DATA_BACKUP_DIR}/
done

echo "backing up secrets"

docker exec ${REMOTE_CONTAINER} ls /secrets | while read F; do
  echo "$F"
  docker cp ${REMOTE_CONTAINER}:/secrets/${F} ${SECRETS_BACKUP_DIR}/
done
