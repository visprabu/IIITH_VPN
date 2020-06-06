#!/bin/bash

## Author: Vishnu Prabu ##

# Script to start/stop OpenVPN service by getting user input(only for first time or if some config files are missing)

# function to start OpenVPN
start_vpn () {
    # checks if already an OpenVPN session is active
    if [ `pgrep openvpn | wc -l` -ge 1 ];
    then   
        echo
        echo "Already an OpenVPN session is active. Please end that session."
        echo
    
    elif [ `pgrep openvpn | wc -l` -eq 0 ];
    then  
        if [ `grep -c "nameserver 10.4.20.204" /etc/resolv.conf` -eq 0 ];
        then
            # Command to add nameserver 10.4.20.204 before the existing nameserver
            `sudo sh -c "sed -i '1i\'\"nameserver 10.4.20.204\" /etc/resolv.conf"`
            echo 
            echo "VPN started"
            echo

            # Command to start OpenVPN as a daemon using config file
            `sudo openvpn --config openvpn.ovpn --daemon`
        else
            echo 
            echo "VPN started"
            echo

            # Command to start OpenVPN as a daemon using config file
            `sudo openvpn --config openvpn.ovpn --daemon`        
        fi
    fi
}

# function to kill/stop all active OpenVPN sessions
stop_vpn () {
    if [ `pgrep openvpn | wc -l` -ge 1 ];
    then
        # killing all active OpenVPN process
        `sudo pkill openvpn`
        
        echo
        echo "VPN stopped"
        echo
    else
        echo
        echo "No Active OpenVPN sessions"
        echo
    fi
}

# function to take user input EmailID and password
user_input () {
    # User Input
    echo -n "Enter IIIT-EmailID: "
    read user

    # only works with mail-id's ending with .iiit.ac.in
    until [ `echo $user | grep -Ec "\..*\@.*\.iiit\.ac\.in$"` -eq 1 ];
    do  
        echo 
        echo "Incorrect EmailID. Please try again."
        echo
        echo -n "Enter IIIT-EmailID: "
        read user
    done      

    echo -n "Enter password: "
    read -s pass

    # wget to download ubuntu.ovpn file
    `wget -o out_wget.txt --user=$user --password=$pass https://vpn.iiit.ac.in/secure/ubuntu.ovpn`
}

# function to check if wget authentication was successful or Failed
ok_error () {

        # If to check wget is 0K ......
        if [ `grep -Ec "0K ......" out_wget.txt` -eq 1 ];
        then
            # adding .auth.txt after auth-user-pass in ubuntu.ovpn and redirecting to openvpn.ovpn
            `cat ubuntu.ovpn | sed 's/\<auth-user-pass\>/& .auth.txt/' > openvpn.ovpn`            
            # user input into .auth.txt
            echo "$user" > .auth.txt
            echo "$pass" >> .auth.txt
            echo

            start_vpn

        # to check if Username/Password Authentication Failed.
        # then asks user input again
        elif [ `grep -Ec "Failed." out_wget.txt` -eq 1 ];
        then
            echo
            echo
            echo "Error: Username/Password Authentication Failed."
            echo

            user_input
            ok_error

        # if anyother error is present
        else
            echo
            echo
            echo "Error: wget error: check out_wget.txt file"
            echo
        fi
}

# Main Program

clear
echo "###########################################"
echo "## Script to start/stop OpenVPN service  ##"
echo "###########################################"
echo "##  >> Type \"1\" to start the service.    ##"
echo "##  >> Type \"0\" to stop the service.     ##"
echo "###########################################"
read choice

if [ $choice -eq 1 ];
then
    # if to check OpenVPN already exists
    if [[ `which openvpn` ]];
    then
        # if to check if already vpn files are downloaded and .auth.txt is generated
        if [[ `find . -name ubuntu.ovpn` ]] && [[ `find . -name .auth.txt` ]];
        then
            start_vpn
        else
            user_input
            ok_error
        fi
    else
        # if OpenVPN is not installed already
        clear
        echo "OpenVPN not installed in your system."
        echo "Installing OpenVPN"
        `sudo apt-get update`
        `sudo apt-get install openvpn`
        echo "Run this script again to start OpenVPN service"
    fi

elif [ $choice -eq 0 ];
then
    # checks if resolv.conf has nameserver 10.4.20.204
    if [ `grep -c "nameserver 10.4.20.204" /etc/resolv.conf` -eq 1 ];
    then
        # command to remove nameserver 10.4.20.204 from /etc/resolv.conf
        `sudo sh -c "sed -i '/nameserver 10.4.20.204/d' /etc/resolv.conf"`

        # removes all files generated or downloaded
        # if needed automatic login into OpenVPN instead of giving credentials each time
        # comment the below line `^rm...txt$``

        #`rm ubuntu.ovpn .auth.txt openvpn.ovpn backup_resolv.conf out_wget.txt`

        stop_vpn 
    else
        stop_vpn
    fi

else
    echo "Invalid option: $choice. Please run the script again with proper option."
fi
