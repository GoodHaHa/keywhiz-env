#!/usr/bin/expect -f
set force_conservative 0  ;# set to 1 to force conservative mode even if
			  ;# script wasn't run conservatively originally
if {} {
	set send_slow {1 .1}
	proc send {ignore arg} {
		sleep .1
		exp_send -s -- 
	}
}



set timeout -1
spawn ./generate_new_certs.sh
match_max 100000
expect "Enter passphrase (empty for no passphrase):"
send -- "ponies\r"
expect "Enter same passphrase again: "
send -- "ponies\r"
expect eof
