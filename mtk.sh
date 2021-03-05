#!/bin/env bash

# List of Colors
Light_Red="\033[1;31m"
Light_Green="\033[1;32m"
Yellow="\033[1;33m"
Light_Blue="\033[1;34m"
Light_Purple="\033[1;35m"
Light_Cyan="\033[1;36m"
NoColor="\033[0m"

function printf_() {
    if [[ $2 == 'title' ]]; then
        printf "\n\n\t\t ${Light_Purple}%s${NoColor} \n" "$1"
    elif [[ $2 == 'header' ]]; then
        printf "\n\n${Light_Cyan} [+] %-20s ${NoColor} \n" "$1"
    else
        printf "  |--[+] %-20s : %b\n" "$1" "$2"
    fi
}

function MD5Salt() {
    req=$(curl -s $_URL_/login | grep -iE 'md5.*password')

    if [[ $(echo $req | wc -m) -le 10 ]]; then
        printf_ "Status" "${Light_Green}Already Logged In${NoColor}"
        printf_ "Disconnect With" "${Yellow}curl -qI -X GET $_URL_/logout${NoColor}"
        exit 0
    fi

    salt1=$(echo "$req" | awk -F "'" '{print $2;}')
    salt2=$(echo "$req" | awk -F "'" '{print $4;}')
    printf "  |--[+] %-20s : " "Encoded Salt"; echo "$salt1$salt2"
    printf_ "Decoded Salt" "$salt1$salt2"
    _salted_pass_=$(printf "$salt1$_PASS_$salt2")
}

function skidipapap() {
    printf_ "Userame" $_USER_
    printf_ "Password" $_PASS_
    printf_ "Hashed Password" $hashed_passwd
    req=$(curl -s -X POST $_URL_/login -d username=$_USER_ -d password=$hashed_passwd -d dst= -d popup=true)

    if [[ $? -eq 0 && $(echo $req | grep -w 'You are logged in' | wc -l) -eq 1 ]]; then
        printf_ "Status" "${Light_Green}SUCCESS${NoColor}"
    else
        printf_ "Status" "${Light_Red}FAILED${NoColor}"
    fi
}

function main() {
    printf_ "Params" header
    printf_ "URL" $_URL_
    printf_ "Username" $_USER_
    printf_ "Password" $_PASS_

    printf_ "Decoding Salt" header
    MD5Salt

    printf_ "Hashing Password" header
    printf_ "Plain Password" "$_PASS_"
    hashed_passwd=$(echo -ne $_salted_pass_ | md5sum | awk '{print $1}')
    printf_ "Hashed Password" "$hashed_passwd"

    printf_ "Connecting" header
    skidipapap
}

clear; printf_ "Automated Login Captive Portal | berrabe" title
if [[ $1 == "" || $2 == "" ]]; then
    printf_ "HELP PAGE" header
    printf_ "Params" "${Yellow}mtk.sh  < URL >  < USER >  < PASS >${NoColor}"
    printf_ "Example 1" "${Light_Blue}mtk.sh https://10.0.0.1 berrabe 12345${NoColor}"
    printf_ "Example 2" "${Light_Blue}mtk.sh https://10.0.0.1 admin${NoColor}"
    exit 1
else
    _URL_=$1
    _USER_=$2
    _PASS_=$3
    main
fi
