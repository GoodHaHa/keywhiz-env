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

Basically, everything. Many external dependencies, but this is a test build, so we won't want to depend on other builds.

* 
