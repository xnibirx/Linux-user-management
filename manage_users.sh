#!/bin/sh -u
PATH=/bin:/usr/bin ; export PATH
umask 022

# ------comment section -------------
# Assignment number - 09
# Name : Nibir Nandi Dibbo , Student number : 041124380
# Course number : CST8102, Lab section : CST8102 312
# Script file name : manage_users
# Submission date : 2 April 2025
#---------------------------Functionality/Pseudocode----------------------------
# Functionality: This script provides a menu-driven interface to manage user accounts on a Linux system.
# All functions asks for user input using read -p command and then performs designated tasks - 1) adding new user using useradd -c comment -d directory -m making directory -s shell username command. 2) changing initial group using usermod -g initial_group username command 3) adding supplementary group by adding group first (groupadd groupname ) then assigning it to user using usermod -a (append) -G groupname. 4) changing shell by command , usermod -s shellname 5)Changing expiration date by usermod -e expiration_date(YYYY-MM-DD) 5)finally deleting user by userldel -r(with home directory) username , command.
#----------------------------------------------------------
# the script uses 2>/dev/null for error suppression
# display_menu shows menu for all stated function for user to perform
# an infinte while loop with break command when user asks for exit
# case takes the value of choice and perform the stated function where both Captital and small cases are regared same using glob pattern [].any value outside range of option is considered invalid
# for choicing q or Q the case exist and  for choosing any other non displayed option, it shows invalid option
# all of the error are directed to stderr stream by changing file descriptor 1 to 2 by echo 1>&2 "(error line)"  . 
# for choosing exit for menu script waits for 3 seconds using sleep 3
# The script clears the screen using clear command after each iteration
# at the end script exits the command using 0 as successful execution 
#-------------------------------------------------------------------------------

add_user() {
    read -p "Enter a username : " user_name
    read -p "Enter user's home directory (absolute path) : " home_dir
    read -p "Enter default login shell (absolute path) : " shell
	
    #Extra : checking if user already exists, 1) checking the username inside /etc/passwd using fgrep command with error suppression(2>/dev/null). 2)If useradd command is successful then username is granted and proceeded for setting password with sudo passwd username, else error is shown in stderr stream (echo 1>&2 "(error message)")
	
    pattern="${user_name}:"
    if sudo fgrep "${pattern}" /etc/passwd 2>/dev/null ; then 
	echo "Username , '${user_name}' already exists..."
    
    elif sudo useradd -c "${user_name}" -d "${home_dir}" -m -s "${shell}" "${user_name}" ; then 
	    echo "Username, '${user_name}'  is granted!"
 	     
	     #Extra: if username is granted sudo passwd prompts user for user input for password, if it fails, it immediately shows error in stderr stream and deletes the granted username with it's home directory using userdel -r command.

	    echo "Setting password for username, '${user_name}'"
	    if sudo passwd "${user_name}" ; then 
		    echo "User '${user_name}' created successfully."
	    else 
		    echo 1>&2 "$0: Error: Failed to set password for '${user_name}'."
            	    sudo userdel -r "${user_name}"
            fi
    else 
        echo 1>&2 "$0: Error: Failed to add user '${user_name}'."
    fi
}



change_initial_group() {
    read -p "Enter username : " user_name
    #Extra : to show what user's current initial group before changing. id -Gn  username shows all the groups assigned to an user, sending that output using | first fields is the initial group, extracting that using cut command where delimiter is space (" "),else clause says, username doesnot exists, cause each user much need a initial group. keeping the whole command inside if block else showing error in stderr.

    if  current_initial_grp=$(id -Gn "${user_name}" | cut -d " " -f1); then
           echo "User, ${user_name}'s current initial group name: ${current_initial_grp}  "
    else
	   echo 1>&2 "$0: Error: User ${user_name} does not exist" 

    fi

    read -p "Enter new initial group name : " group
    sudo usermod -g "${group}" "${user_name}"
   	

    if [ $? -ne 0 ]; then
        echo 1>&2 "$0: Error: Failed to change initial group to '${group}'."
    fi
}

change_supplementary_group() {
    
    read -p "Enter username : " user_name
    #Extra : same way as before , showing the current supplementary group where cut command extract the second field from id -Gn command. if this command fails then supplementary group return an non empty string which checked using -n in test command (elif command).***since -f2- sends only primary group name when there is no supplementary group, (to solve this) using wc -w gives value of 1, it means username doesnot have supplementary group rather just a primary group (if clause).
	
    current_sup_grp=$(id -Gn "${user_name}" | cut -d " " -f2-)
    
    if [ $(echo "${current_sup_grp}" | wc -w ) -eq 1  ] ; then 
	    echo "${user_name} just have a primary group but no supplementary groups"

    elif  [ -n "${current_sup_grp}"  ]; then
    	   echo "User, ${user_name}'s current supplementary group names: ${current_sup_grp}.  "
    else
           echo 1>&2 "$0: Error: Failed to show supplementary group names"

    fi 

    read -p "Enter supplementary group name : " sup_group
    # adding the group first, error suppression in case of group being already existing.Then appending with current user's groups and adding the argument as supplementary group

    sudo groupadd "${sup_group}" 2>/dev/null
    sudo usermod -aG "${sup_group}" "${user_name}"
	
    
    if [ $? -ne 0 ]; then
        echo "$0: Error: Failed to add supplementary group '${sup_group}'." >&2
    fi
}

change_shell() {
    read -p "Enter username : " user_name
    
 #Extra:if username exists showing current login shell if it exists, using fgrep command with pattern to find out designated userinfo line for /etc/passwd file and extracting field 7 for the line which is the value of shell. here each field is separated by delimiter so cut -d : is used 

    pattern="${user_name}:"	
    
    if user_name_line=$(sudo fgrep "${pattern}" /etc/passwd 2>/dev/null) ; then
 
 	    current_shell=$( echo "${user_name_line}" | cut -d : -f 7 )
 	    echo "current shell of '${user_name}': ${current_shell}."
	    read -p "Enter login shell (absolute path) : " login_shell
 	    sudo usermod -s "${login_shell}" "${user_name}"
 	    
    else 
	    echo 1>&2 "username '${user_name}' does not exist."
	
    fi


    if [ $? -ne 0 ]; then
     	    echo 1>&2 "$0: Error: Failed to change shell to '${login_shell}'." 
    fi
}

change_expiration_date() {
    read -p "Enter username : " user_name
    read -p "Enter expiration date (YYYY-MM-DD) : " expiration_date

    sudo usermod -e "${expiration_date}" "${user_name}"
    
    if [ $? -ne 0 ]; then
        echo 1>&2 "$0: Error: Failed to set expiration date '${expiration_date}'."
    fi
}

delete_user_account() {
    read -p "Enter username : " user_name

    sudo userdel -r "${user_name}" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo 1>&2"$0: Error: Failed to delete user '${user_name}'."
    fi
}

display_menu() {
    echo "User Account Management Menu"
    echo "A) Add a user account"
    echo "I) Change initial group"
    echo "S) Change supplementary group"
    echo "L) Change login shell"
    echo "E) Change expiration date"
    echo "D) Delete user account"
    echo "Q) Quit"
    echo
}

while true; do
    clear
    display_menu
    read -p "Enter your choice: " choice

    case "$choice" in
        [Aa]) add_user ;;
        [Ii]) change_initial_group ;;
        [Ss]) change_supplementary_group ;;
        [Ll]) change_shell ;;
        [Ee]) change_expiration_date ;;
        [Dd]) delete_user_account ;;
        [Qq]) echo "Exiting..."; break ;;
        *) echo "$0: Error: Invalid option '$choice'" >&2 ;;
    esac
	# second comparison is checked when first comparsion is giving exit status of 0
	# waiting if choice is not exit
    if [ "$choice" != "Q" ] && [ "$choice" != "q" ]; then
        sleep 3
    fi
done

exit 0

