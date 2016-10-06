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

* . ./.setup
* ./kwcli.sh list clients

It will ask your password, but should work.
