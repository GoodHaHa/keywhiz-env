#!/bin/bash

docker run -d \
    -v keywhiz-data:/data \
    -v keywhiz-secrets:/secrets \
    -p 127.0.0.1:4444:4444 \
    -e KEYWHIZ_CONFIG=/data/keywhiz-docker.yaml \
    --name "keywhiz-server" \
    square/keywhiz server

