#!/bin/bash

echo "cleaning up data volumes"
docker volume rm keywhiz-data
docker volume rm keywhiz-secrets

docker run -it --rm \
    -v keywhiz-data:/data \
    -v keywhiz-secrets:/secrets \
    square/keywhiz wizard

echo "You can start ./wizard-start.sh"

