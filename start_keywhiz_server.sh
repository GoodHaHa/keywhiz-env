#!/bin/bash

echo "--> stopping and cleaning up old keywhiz server"
docker ps -a | grep 'square/keywhiz' | awk '{print $1}' | while read CONTAINER; do docker stop ${CONTAINER}; docker rm -v ${CONTAINER};done

docker volume rm keywhiz-db
docker volume create --name keywhiz-db

volumes="-v $(pwd)/config/keywhiz-config.yml:/keywhiz-config.yml -v $(pwd)/certstrap/out/truststore.p12:/truststore.p12 -v $(pwd)/certstrap/out/keystore.p12:/keystore.p12 -v $(pwd)/config/keywhiz.crl:/keywhiz.crl -v $(pwd)/config/derivation.jceks:/derivation.jceks"

echo "--> migrating"
docker run ${volumes} --rm -e KEYWHIZ_CONFIG=/keywhiz-config.yml -v keywhiz-db:/data square/keywhiz migrate

echo "--> creating admin user"
docker run --rm -it ${volumes} -e KEYWHIZ_CONFIG=/keywhiz-config.yml -v keywhiz-db:/data square/keywhiz add-user

echo "--> starting keywhiz server"
docker run --rm -it ${volumes} -e KEYWHIZ_CONFIG=/keywhiz-config.yml -v keywhiz-db:/data square/keywhiz server

