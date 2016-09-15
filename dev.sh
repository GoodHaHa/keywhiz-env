#!/bin/bash

docker run -it --rm \
    -v keywhiz-data-dev:/data \
    -v keywhiz-secrets-dev:/secrets \
    square/keywhiz migrate

docker run -it --rm \
    -v keywhiz-data-dev:/data \
    -v keywhiz-secrets-dev:/secrets \
    square/keywhiz add-user

docker run -it --rm \
    -v keywhiz-data-dev:/data \
    -p 127.0.0.1:4444:4444 \
    -v keywhiz-secrets-dev:/secrets \
    square/keywhiz server
