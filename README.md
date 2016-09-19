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

In the end of the process, you should see
```
---- Keywhiz OK ----
```

It means, that the client (keywhiz-fs) is able to reach the server, and the server status is "ok".
