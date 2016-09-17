#!/bin/bash

set -u
set -e
set -o pipefail

. ./.env

echo "---> cleaning up generated keys"
rm -rvf ${SECRET_DIR}/*

echo "---> cleaning up running containers"
set +e
docker ps | grep keywhiz | awk '{print $1}' | while read CONTAINER; do
  echo "stopping: ${CONTAINER}"
  docker stop ${CONTAINER}

  echo "removing: ${CONTAINER}"
  docker rm -v ${CONTAINER}
done

echo "--> cleaning up stopped containers"
docker ps -a | grep keywhiz | grep 'Exited' | while read CONTAINER; do
  echo "removing: ${CONTAINER}"
  docker rm -v ${CONTAINER}
done

echo "--> removing docker volumes"
set +e
docker volume ls | grep keywhiz | awk '{print $2}' | while read VOLUME; do
  echo "removing volume: ${VOLUME}"
  docker volume rm ${VOLUME}
done
set -e
