#!/bin/bash

docker run -ti --add-host "${KEYWHIZ_HOSTENTRY}" --rm keywhiz-cli --user ${KEYWHIZ_ADMIN_USER} --url ${KEYWHIZ_URL} $@
