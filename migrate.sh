#!/bin/bash

docker run -it --rm \
    -v keywhiz-data:/data \
    -v keywhiz-secrets:/secrets \
    -e KEYWHIZ_CONFIG=/data/keywhiz-docker.yaml \
    square/keywhiz migrate
