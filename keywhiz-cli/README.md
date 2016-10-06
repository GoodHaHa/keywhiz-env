Preparations
============

* ``` cp .env.example .env ```
* setup your password in the ```.env``` file
* ``` cp .setup.example .setup ```
* setup your keywhiz url, admin user name in the ``` .setup file ```
* Copy your truststore to this directory, as ```ca-bundle.p12```
* ``` docker build -t keywhiz-cli . ```

Usage
=====

## Listing clients
* ```./kwcli.sh list clients```

It will ask your password for the first time.

## Adding secrets

The original syntax is ``` keywhiz.cli add secret --name mySecret.key --group myGroup < mySecretContents.key ``` 
But it won't work in docker, so instead of ``` < mySecretContents.key ```, write ``` --file mySecretContentsKey ```


