#!/bin/bash

set -uo pipefail

if which expect &>/dev/zero; then
  echo 'expect OK'
else
  echo 'please install expect'
  exit 1
fi

if docker info &>/dev/zero; then
  echo 'docker OK'
else
  echo 'please install docker, and ensure its running'
  exit 1
fi

if which envsubst &>/dev/zero; then
  echo 'envsubst OK'
else
  echo 'please install gettext-base (for envsubst)'
  exit 1
fi
