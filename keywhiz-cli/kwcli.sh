#!/bin/bash

set -euo pipefail

INSERT_FILE=""

if [[ -f .env ]]; then
  . ./.env
fi

H=${HOME}

if [[ ! -d ${H}/.keywhiz-tmp ]]; then
  mkdir -pv ${H}/.keywhiz-tmp
fi

FILE_FLAG=0
NEXT_PARAMS=""
EXTRA_VOLUME_COMMAND=""

for var in "$@"
do
  if [[ ${FILE_FLAG} == 1 ]]; then
    INSERT_FILE="${var}"
    NEXT_PARAMS="${NEXT_PARAMS} ${var}"
  elif [[ "${var}" == '--file' ]]; then
    echo "we are trying to use a file, transforming"
    FILE_FLAG=1
    NEXT_PARAMS="${NEXT_PARAMS} ${var}"
  else
    NEXT_PARAMS="${NEXT_PARAMS} ${var}"
  fi
done

if [[ ${FILE_FLAG} == 1 ]]; then
    if [[ ${#INSERT_FILE} -lt 1 ]]; then
        echo "You should specify a file after --file"
        exit 1
    fi
    echo "got file param: ${INSERT_FILE}"
    echo "final parameters: ${NEXT_PARAMS}"
    if [[ ! -f ${INSERT_FILE} ]]; then
      echo "file: ${INSERT_FILE} does not exists"
      exit 1
    fi

    EXTRA_VOLUME_COMMAND=" -v $(pwd)/${INSERT_FILE}:/tmp/${INSERT_FILE}"
fi

docker run -ti ${EXTRA_VOLUME_COMMAND} -v ${H}/.keywhiz-tmp:/root --add-host "${KEYWHIZ_HOSTENTRY}" keywhiz-cli ${NEXT_PARAMS}
