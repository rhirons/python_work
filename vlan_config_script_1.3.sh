#!/usr/bin/env bash
# Ross H - April 2018
# Work in progress script to restore non-persistent vlan interfaces after reboot or crash.

## ----------------------------------
# Step #1: Define global variables
# ----------------------------------
RED='\033[0;41;30m'
STD='\033[0;0;39m'
 
CURRENT_DIR=$(pwd)

# ----------------------------------------
# Step #2: User defined function for menus
# ----------------------------------------
pause(){
  read -p "Press [Enter] key to continue..."
}

one(){
	 backup_configs
	 pause
}
 
# do something in two()
two(){

	if check_for_root; then
		check_file
		construct_commands
		restore_configs
		pause
	else
		exit 1
	fi
}
 
#Function will run ip command to dump nic configs to file (ip_backup). This is for reference in case the script fails to restore and we need to bring them up manually.
#Contents will then be cleaned and stored in seperate file (ip_backup_clean) which will be used to construct ip commands.
backup_configs() {
#Dumps raw configs for reference.
ip addr show > "$CURRENT_DIR/ip_backup" 
ip route show > "$CURRENT_DIR/ip_static_route_backup"

#Cuts out undeeded data for use later on when contructing ip commands.
ip r | grep "via" | grep -E -v "default|tve" | cut -d' ' -f1,3,5 > "$CURRENT_DIR/ip_static_route_clean"
ip a | grep inet | grep -Ev 'jump|cin|127|tve' | cut -d' ' -f6,8,11 > "$CURRENT_DIR/ip_backup_clean" #Cleans output so only non-persistent vlan interfaces are picked.

echo
echo "IP addresses for currently configured vlans and static routes have been backed up in the current directory."
echo "Use this to manually restore interfaces if the script fails to restore."
echo
echo "DONE! You can now reboot ns02 and restore the configs"
echo

}

#Makes sure a backup has been performed first and deletes old restore file if it exists.
check_file () {
if [ ! -e "$CURRENT_DIR/ip_backup_clean" ]; then
	echo "ERROR. Can't find backup file for interfaces (ip_backup_clean)."
	echo "Did you run option 1 first?"
	echo "Please make sure ip_backup_clean is in the same directory as this script"
	exit 1
fi
if [ -e "$CURRENT_DIR/ip_restore_commands" ]; then
	echo "Old restore file found. Deleting..."
	echo
	sleep 2
	rm "$CURRENT_DIR/ip_restore_commands"    
fi
}

#Does what it says on the tin.
check_for_root () {
echo
echo "Checking if you are running the script as root..."
sleep 2
if [[ $UID != 0 ]]; then
	echo "ERROR. Restore option must be run as root. Quitting."
	false
else
	echo "You're root! Happy days. Continuing...  "
	sleep 1
	true
fi
}

#Loops through the cleaned output to construct ip commands that will bring up the vlan interfaces.
#I've still to manually add lines to bring up the physical interfaces first (switch2,3,9,11,12)
construct_commands () {
echo
echo "Generating commands..."
while read line; do
#Chop out required info from file into seperate variables.
ipaddrr=$(echo "$line" | cut -d ' ' -f 1)
brdcast=$(echo "$line" | cut -d ' ' -f 2)
interface_name=$(echo "$line" | cut -d ' ' -f 3)
switch_port=$(echo "$interface_name" | cut -d '.' -f 1)
vlan_num=$(echo "$interface_name" | cut -d '.' -f 2)

create_vlan_link="link add link $switch_port name $interface_name type vlan id $vlan_num"
assign_ip="addr add $ipaddrr brd $brdcast dev $interface_name"
up_interface="link set dev $interface_name up"

echo -e "$create_vlan_link\\n$assign_ip\\n$up_interface\\n" >> ip_restore_commands
echo "$interface_name...done."
done < ip_backup_clean

#Now do the static routes for the NE's
while read line; do
ip_subnet=$(echo "$line" | cut -d ' ' -f 1)
gateway=$(echo "$line" | cut -d ' ' -f 2)
vlan_interface=$(echo "$line" | cut -d ' ' -f 3)

add_route="route add $ip_subnet via $gateway dev $vlan_interface"
echo -e "$add_route" >> ip_route_commands
done < ip_static_route_clean
}

#Uses ip batch (-b) option and feeds in list of commands from ip_restore_commands file.
restore_configs () {
	echo
	echo "Attempting to restore network config..."
	sleep 1
	ip -b "$CURRENT_DIR/ip_restore_commands" - Commented out line while testing script!
	ip -b "$CURRENT_DIR/ip_route_commands"   - Commented out line while testing script!
}

 
# function to display menus
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Backup Configs to current dir"
	echo "2. Restore Configs"
	echo "3. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options(){
	local choice
	read -p "Enter choice [ 1 - 3] " choice
	case $choice in
		1) one ;;
		2) two ;;
		3) exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}
 
# ----------------------------------------------
# Step #3: Trap CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
 	show_menus
	read_options
done

