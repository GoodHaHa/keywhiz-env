#!/bin/bash

set -xeuo pipefail

. ./.env

H=$(pwd)

if [[ ! -d ${H}/.keywhiz-tmp ]]; then
  mkdir -pv ${H}/.keywhiz-tmp
fi

docker run -ti -v ${H}:/root --add-host "${KEYWHIZ_HOSTENTRY}" keywhiz-cli $@
