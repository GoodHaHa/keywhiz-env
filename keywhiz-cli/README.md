Preparations
============

* ``` cp .env.example .env ```
* setup your password and other stuff in the ```.env``` file
* Copy your truststore to this directory, as ```ca-bundle.p12```
* ``` docker build -t keywhiz-cli . ```

Usage
=====

## Listing clients
* ```./kwcli.sh list clients```

It will ask your password for the first time.

## Adding secrets

* ``` ./kwcli.sh add secret --name SecretFile.key --file SecretFile.key ```
