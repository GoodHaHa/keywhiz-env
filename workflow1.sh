#!/bin/bash

set -e
set -u
set -o pipefail

### ensure repositories are in place ###
cat repo_list.txt | grep -v '^$' | while read LN; do
  ./ensure_repo.sh "${LN}"
done

### build certstrap
echo "--> building certstrap"
( cd certstrap;
  ./build
)

### build keywhiz
echo "--> building keywhiz"
( cd keywhiz;
  docker build --rm --force-rm -t square/keywhiz .
)

### build keywhiz-fs

echo "--> building keywhiz-fs"
( cd keywhiz-fs;
  docker build --rm -t square/keywhiz-fs .
)

echo "you may want to generate new certs with "
echo "./generate_new_certs.sh"

