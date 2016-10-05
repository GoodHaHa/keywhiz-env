#!/bin/bash

set -ueo pipefail

MACHINE_HOST="$1"

echo "checking ${MACHINE_HOST}"
if ! docker-machine env ${MACHINE_HOST}; then
  echo "host ${MACHINE_HOST} does not exists in machine"
  exit 1
fi

eval $(docker-machine env ${MACHINE_HOST} || exit 1)

echo "terminating copyreceiver if any"
docker stop copyreceiver || true
docker rm -v copyreceiver || true

echo "--> removing old volumes"
docker volume rm keywhiz-data || true
docker volume rm keywhiz-secrets || true

echo "--> creating new volumes"
docker volume create --name keywhiz-data
docker volume create --name keywhiz-secrets

echo "--> starting receiver container"
docker run -d --name copyreceiver -v keywhiz-data:/keywhiz-data -v keywhiz-secrets:/keywhiz-secrets busybox yes

echo "--> provisioning receiver container"
ls keywhiz-data | while read ENTRY; do
  docker cp keywhiz-data/${ENTRY} copyreceiver:/keywhiz-data/
done

ls keywhiz-secrets | while read ENTRY; do
  docker cp keywhiz-secrets/${ENTRY} copyreceiver:/keywhiz-secrets/
done

echo "--> setting up permissions within the volume"
docker exec copyreceiver chmod -R 666 /keywhiz-secrets/
docker exec copyreceiver chmod -R 666 /keywhiz-data/

echo "--> cleaning up"
docker stop copyreceiver
docker rm -v copyreceiver

