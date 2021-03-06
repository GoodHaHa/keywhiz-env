#!/bin/bash

set -euo pipefail

docker-machine env ${1} # it will fail if its incorrect
eval $(docker-machine env ${1})

docker run -d \
    -v keywhiz-data:/data \
    -v keywhiz-secrets:/secrets \
    -p 4444:4444 \
    -e KEYWHIZ_CONFIG=/data/keywhiz-docker.yaml \
    --name keywhiz_server \
    gyulaweber/keywhiz server

