#!/bin/bash

rm -rfv keywhiz-data/*
rm -rfv keywhiz-secrets/*
docker run --rm -v $(pwd)/keywhiz-data:/srv -v keywhiz-data:/opt ubuntu:trusty bash -c 'cp -vr /opt/* /srv/'
docker run --rm -v $(pwd)/keywhiz-secrets:/srv -v keywhiz-secrets:/opt ubuntu:trusty bash -c 'cp -vr /opt/* /srv/'

