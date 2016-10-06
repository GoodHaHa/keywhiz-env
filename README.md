Goal
====

Ease start using keywhiz in a secure way.

- [x] Make it work
- [ ] Make it right

Dependencies
============

* Ubuntu xenial
* Docker Engine 1.12.1
* expect, jq

What it does
============

It generates every cert stuff, passwords, so it won't be the insecure / developer version.

How can I try it out
====================

* run ``` cp .env.example .env ```
* edit the file to fit your needs (server ip, server domain is important if want to use it remotely)
* run ``` ./everything.sh ```
* run ``` ./test.sh ```

In the end of the process, you should see
```
---- Keywhiz OK ----
```

It means, that the client (keywhiz-fs) is able to reach the server, and the server status is "ok".

