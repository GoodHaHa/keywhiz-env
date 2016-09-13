#!/bin/bash

set -e
set -u
set -o pipefail

REPO_NAME=$(basename "${1}" .git)
if [[ ! -d "${REPO_NAME}" ]]; then
    echo "--> cloning into ${REPO_NAME}"
    git clone --depth 1 "${1}"
else
    echo "--> updating ${REPO_NAME}"
    (cd ${REPO_NAME}; git pull)
fi

echo "--> script done"
