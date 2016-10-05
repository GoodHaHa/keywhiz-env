#!/bin/bash

docker run -it --rm \
    -v keywhiz-data:/data \
    -v keywhiz-secrets:/secrets \
    -p 4444:4444 \
    -e KEYWHIZ_CONFIG=/data/keywhiz-docker.yaml \
    gyulaweber/keywhiz server

