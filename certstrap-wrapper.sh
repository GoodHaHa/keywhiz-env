#!/bin/bash

echo "--> calling certstrap with $@"

PASSWORD="$1"
shift
PARAMS="$@"
cd certstrap
PARAMS="${PARAMS}" PASSWORD=${PASSWORD} envsubst < ../certstrap-wrapper.exp >../run.sh
chmod +x ../run.sh
../run.sh
rm ../run.sh
