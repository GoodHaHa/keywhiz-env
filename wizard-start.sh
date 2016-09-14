#!/bin/bash

docker run -it --rm \
    -v keywhiz-data:/data \
    -v keywhiz-secrets:/secrets \
    -p 127.0.0.1:4444:4444 \
    -e KEYWHIZ_CONFIG=/data/keywhiz-docker.yaml \
    square/keywhiz server

