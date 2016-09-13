#!/bin/bash

volumes="-v $(pwd)/config/keywhiz-config.yml:/keywhiz-config.yml -v $(pwd)/certstrap/out/truststore.p12:/truststore.p12 -v $(pwd)/certstrap/out/keystore.p12:/keystore.p12 -v $(pwd)/config/keywhiz.crl:/keywhiz.crl"

echo "cleaning up"
rm -v config/deviration.jceks

echo "--> gen-aes"
docker run --entrypoint 'java' --name tmp-gen-aes -it ${volumes} -w /home/keywhiz -e KEYWHIZ_CONFIG=/keywhiz-config.yml -v keywhiz-db:/data square/keywhiz -jar /usr/src/app/server/target/keywhiz-server-0.7.11-SNAPSHOT-shaded.jar gen-aes
docker cp tmp-gen-aes:/home/keywhiz/derivation.jceks config/derivation.jceks
docker rm -v tmp-gen-aes
