#!/bin/bash

set -e
set -u
set -o pipefail

echo "--> building tmp container"
cd tmp_container
docker build -t tmp_keywhiz_stuff .
cd ..

### ensure repositories are in place ###
cat repo_list.txt | grep -v '^$' | while read LN; do
  ./ensure_repo.sh "${LN}"
done

### build certstrap
echo "--> building certstrap"
( cd certstrap;
  docker run -ti --rm -v $(pwd):/srv -w /srv golang ./build
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

echo "--> generating certifications with password 'ponies'"
./generate_new_certs.sh

echo "--> running migration"
./migrate.sh

echo "--> adding user"
./add-user.sh

echo "--> starting server"
./start.sh