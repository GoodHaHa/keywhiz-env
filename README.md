Goal
====

Ease start using keywhiz in a secure way.

1. Make it work
2. Make it right

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

In the end of the process, you should see
```
---- Keywhiz OK ----
```

It means, that the client (keywhiz-fs) is able to reach the server, and the server status is "ok".

How to try out with AWS
=======================

!!! WARNING !!! It may cost you, please check keywhiz_env.tf for resource details, and run ``` tf plan ``` before you do anything. I can't, and I won't take any responsibility about the consequences.

* Setup you server.tf with your aws credentials, like
```
access_key = "YOUR_ACCESS_KEY"
secret_key = "YOUR_SECRET_KEY"
```
* put your public ssh key to variables.tf
* install terraform
* ``` terraform apply --var-file server.tf ```

After ~10 minutes, you should see this:
```
aws_instance.example: Still creating... (10m30s elapsed)
aws_instance.example (remote-exec): keywhiz-server
aws_instance.example (remote-exec): keywhiz-server
aws_instance.example (remote-exec): ---- Keywhiz OK -----
aws_instance.example: Creation complete

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate
```

### What it does

A lots of thigs. Many external dependencies, but this is a test build, so we won't want to depend on other builds.

* When you start terraform, it reads keywhiz_env.tf, the variables.tf, and your aws credentials, and starts a small instance (the build was unsuccessful with a nano instance, java heap space.. yeah I know I know.. java...... :)
* Then it calls a single script which does everything: provision/docker.sh. Later, it should be separated, but for now, I just wanted the whole process to be run at once, as it's much easier to separate things which is knowns to be working, than put pieces together until it works.
* installs docker and its dependendies
* installs fuse, jq, git, expect
* setup fuse: user_allow_other
* clone this repository (https://github.com/gyulaweber/keywhiz-env.git)

At this point, everything should be ready to build all of the things

* calls ./everything.sh, which
* check if everything seems to be ready (docker, expect, ...)
* clones the ORIGINAL keywhiz, certstrap, and keywhiz-fs repos (https://github.com/square/keywhiz), the list is in the repo_list.txt file
* build a temporary image, just with java8 and a few things (see builder/Dockerfile)
* build certstrap with the help of the golang docker image
* build keywhiz with the original dockerfile which we just cloned. It fetches all dependencies and do the build.
* build keywhiz-fs with the help of the golang docker image. The purpose is to have keywhiz-fs in the host, not in the container.

* calls ./generate_new_certs, which will
* include the .env file, which generates passwords, and assings them to the variables. Later, we'll use it with ensubst.
* create content keystore (AES)
* create CA
* create client crt, and sign it
* create server crt, and sign it
* builds truststore
* builds keystore
* create client.pem from client.crt and client.key, to have a shorter command line when calling keywhiz-fs
* create docker volumes for secret / data storing
* copy things to the volume
* run the migration
* add the user

* Then, the provision script calls the test script, which does the following
* start the keywhiz server in the background (docker container in the background)
* wait for the port to open
* create a temporary mount point
* starts keywhiz-fs with the generated client pem
* tries to read the .json/server_status from the mounted FUSE filesystem, and checks the server_status
* if the server_status contains "ok", then the script will return 0, so the process is success. Otherwise, fails.

