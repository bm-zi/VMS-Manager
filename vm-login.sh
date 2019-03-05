#!/bin/bash 



# Author: Bahram Z.
# This script brings up local VM and then
# automate ssh login.
# 'expect' need to be installed.

# Booting up a local VBox VM and automate login



   echo "[LOGGING OUTPUT]  SCRIPT STARTED!"

   VBoxManage startvm webapp --type headless
   sleep 30

   /usr/bin/expect <(cat << EOF
spawn ssh -p 2222  -X root@localhost
expect { 
	"yes/no" { 
		send "yes\r"
		exp_continue
	}
	"password:" {
		send "MyPassword\r"
		exp_continue
	}
}
interact
EOF
)
   echo "[LOGGING OUTPUT]  SCRIPT COMPLETED!"
