Goal
====

Ease start using keywhiz in a secure way.

Dependencies
============

* Ubuntu xenial
* Docker Engine 1.12.1
* expect, jq

What it does
============

It generates every cert stuff, passwords, so it won't be the insucere / developer version.

How can I try it out
====================

* run ``` ./everything.sh ```
* run ``` ./test.sh ```

Try it out with AWS
===================
* install terraform
* put your public key into variables.tf
* create a file with your aws credentials (full ec2 access) into a file, with
```
access_key=YOUR_ACCESS_KEY
secret_key=YOUR_SECRET_KEY
```
run
```
terraform apply --var-file YOUR_AWS_CREDENTIALS_FILE
```

In the end of the process, you should see
