#!/bin/bash

#./everything.sh
./start-daemon.sh
while ! nc -q 1 localhost 4444 </dev/null; do echo "waiting for port.."; sleep 1; done
sleep 5 # assume it's enough time to initialize

if [[ ! -d kwfs ]]; then
  mkdir -pv kwfs
fi

(./fs.sh $(pwd)/kwfs &)
sleep 5
STATUS=$(cat $(pwd)/kwfs/.json/server_status | jq .status)
echo "status: ${STATUS}"


killall keywhiz-fs
sleep 1
fusermount -u $(pwd)/kwfs

docker stop keywhiz-server
docker rm -v keywhiz-server

if [[ "${STATUS}" == '"ok"' ]]; then
  echo "---- Keywhiz OK -----"
  exit 0
else
  echo "---- Keywhiz FAILED -----"
  exit 1
fi
