#!/usr/bin/env bash

# Author: Bahram Z.
# This is a simple menu-based bash script to manage,
# all the VM's running on a Linux host.
# All VM's imported or created in Oracle VirtualBox can be viewed,
# and be started or stopped buy running this script.



# Function: Display a menu of VMS 
function show_vms(){
arr=( $( vboxmanage list vms | sed 's/^"\(.*\)".*/\1/' ) )
echo "VMS available for Oracle VirtulaBox"
echo "___________________________________"
n=1
for i in "${arr[@]}"; do
	echo "$n - $i "
   let n++ 
done
}

# Function: check if vm is up or down
function vm_stat(){
	vmno=$(( $1 - 1 ))
	arr=( $( vboxmanage list vms | sed 's/^"\(.*\)".*/\1/' ) )
   # grep -c or --count means counting the number of matches found
	local stat=$( vboxmanage showvminfo "${arr[$vmno]}" | grep -c 'running (since' )
   echo "$stat"  # if stat is "0",  vm is not running. "1" means vm is up
}


# Function: stop/start vm
function stopstart(){
   vm=$1
   vmno=$(( $1 - 1 ))
	arr=( $( vboxmanage list vms | sed 's/^"\(.*\)".*/\1/' ) )
	
	# By function substitution we retun the function value to variable stat
   stat=$(vm_stat $vm)  
   if [ "$stat" -ne "0" ]; then
		read -p "VM is up ! Shut it Down? [d]: " c
      if [ "$c" == "d" ]; then
			VBoxManage controlvm ${arr[$vmno]}  poweroff
			echo "Machine stopped!"
		else
			main_fct
		fi
	else
		read -p "VM is down! Start it Up? [u]: " c
      if [ "$c" == "u" ]; then
			VBoxManage startvm ${arr[$vmno]} --type headless
			echo "Machine started!"
		else
			main_fct
		fi
	fi   
}


# Function: show vm description
function vm_desc() {
	vm=$1
   vm_no=$(( $vm - 1 ))
	arr=( $( vboxmanage list vms | sed 's/^"\(.*\)".*/\1/' ) )
	echo "Option $vm : ${arr[$vm_no]} "
   echo ""
	vboxmanage showvminfo ${arr[$vm_no]} | sed -n '/^Description:/,/^Guest:/p' | sed 's/Guest://g'
}



# Function: Display waiting prompt
# $1-> Message (optional)
function waiting(){
	local message="$@"
	[ -z $message ] && message="Press [Enter] key to continue..."
	read -p "$message" readEnterKey
}


# Function: shows vm description and execute required action
function action(){
   vmno=$1
	echo ""
	vm_desc $vmno	
   stopstart $vmno 
	waiting
}


# Function: Get input via the keyboard and make a decision using case..esac 
function read_input(){
	vmsNo=$( vboxmanage list vms | wc -l )
	local c
	read -p "Enter your choice [ 1 - $vmsNo ] -  [q] to quit! " n
	if [[ "$n" -le $vmsNo  &&  "$n" -ne "" ]]; then
			action $n
	elif [[ "$n" == 'q' ]]; then
   		exit 0
	else	
			echo "Please select between 1 to $vmsNo choice only."
      	waiting
	fi
}


# Function: main logic
function main_fct(){
while true; do
	clear
	show_vms # display memu
	read_input # wait for user input
done
}
main_fct
