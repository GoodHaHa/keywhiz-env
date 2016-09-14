#!/bin/bash

docker run -it --rm \
    -v keywhiz-data:/data \
    -v keywhiz-secrets:/secrets \
    square/keywhiz wizard

echo "You can start ./wizard-start.sh"

