#!/bin/bash

set -e
set -u
set -o pipefail

### ensure repositories are in place ###
cat repo_list.txt | grep -v '^$' | while read LN; do
  ./ensure_repo.sh "${LN}"
done
