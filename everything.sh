#!/bin/bash

set -e
set -u
set -o pipefail

echo "--> checking dependencies"
./check_deps.sh

echo "--> building tmp container"
( cd builder;
  docker build -t tmp_keywhiz_stuff .
)

cat repo_list.txt | grep -v '^$' | while read LN; do
  ./ensure_repo.sh "${LN}"
done

echo "--> building certstrap with golang"
( cd certstrap;
  docker run -ti --rm -v $(pwd):/srv -w /srv golang ./build
)

echo "--> building keywhiz"
( cd keywhiz;
  docker build --rm --force-rm -t square/keywhiz .
)

echo "--> building keywhiz-fs"
( cd keywhiz-fs;
  echo "----> installing keywhiz-fs dependencies; it may take a while..";
  docker run -ti --rm -v $(pwd):/srv -w /srv -e GOPATH=/srv golang go get -d ./...
  echo "----> building keywhiz-fs"
  docker run -ti --rm -v $(pwd):/srv -w /srv -e GOPATH=/srv golang make keywhiz-fs
  sudo mv srv /usr/local/bin/keywhiz-fs

)
# docker build --rm -t square/keywhiz-fs . # it works, but I want keywhiz-fs on the host

echo "--> generating certifications with password 'ponies'"
./generate_new_certs.sh
