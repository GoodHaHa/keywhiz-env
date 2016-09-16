Goal
====

Ease using keywhiz

Purpose
=======

The sole purpose of this project is to ease the adaptation of the tools by providing working examples.

Features
========

* Launch a keywhiz server and keywhiz-fs in two different nodes with newly generated keys (so it will be more secure out-of-the-box)
* Configuration by environment variables

## How to build keywhiz-fs locally (not docker)

### Build keywhiz-fs
```
cd keywhiz-fs
docker run -ti --rm -v $(pwd):/srv -w /srv golang bash -c 'go get ./...;make keywhiz-fs'
```

### Mount
```
cd certstrap/out
keywhiz-fs --key client.pem --ca Keywhiz_CA.crt https://127.0.0.1:4444 /secret/kwfs
```

