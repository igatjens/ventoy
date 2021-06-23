#! /bin/bash

#*******************************************************************
#
#	Ventoy Wizard
#
#	Wizard to install and update Ventoy on USB storage drives
#
# 	Isaías Gätjens M.
#
#	Email: igatjens@gmail.com
#	GitHub: github.com/igatjens
#	Twitter: twitter.com/igatjens
#
#	License: GNU GPLv3
#
#*******************************************************************

USB_DRIVES=()
USB_DRIVE_SELEC=""

PARAMETERS=""

proc-exit () {
	echo "Press Enter to finish"
	read OPTION
	exit 0
}

proc-canceled () {

	echo "Procedure canceled"
	proc-exit
}

get-usb-drives () {
	LIST="$(ls -l /dev/disk/by-path/ | grep usb | cut -d "/" -f3 | sed "s|[0-9]||g" | uniq | sort )"

	INDEX=1
	for i in $LIST; do
		
		USB_DRIVES[$INDEX]="/dev/${i}"
		let INDEX++
	done
}


print-usb-drives-info () {

	if [[ ${USB_DRIVES[@]} ]]; then
		
		echo -e "\n----------------------------"
		echo -e "USB storage drives\n"
		lsblk -o NAME,LABEL,SIZE,FSTYPE,PATH ${USB_DRIVES[@]}
	else
		echo -e "\n----------------------------"
		echo -e "No USB storage drives available\n"
	fi
}

print-usb-drives () {

	INDEX=1
	for i in ${USB_DRIVES[@]}; do
		echo ${USB_DRIVES[$INDEX]}
		let INDEX++
	done
}

selec-usb-drive () {

	if [[ ${USB_DRIVES[@]} ]]; then
		
		KEEP=true	
		while [[ $KEEP == true ]]; do
			
			OPTION=""

			clear

			print-usb-drives-info

			echo -e "\n----------------------------"
			echo "Select one of the USB drives"

			COUNT=1
			for i in $(print-usb-drives); do
				echo "$COUNT) ${i}"
				let COUNT++
			done
			echo -e "C) Cancel\n"

			read OPTION

			case "$OPTION" in
				C|c )
					proc-canceled
					;;
				* )
					if [[ $OPTION -ge 1 ]] && [[ $OPTION -le ${#USB_DRIVES[@]} ]]; then

						USB_DRIVE_SELEC="${USB_DRIVES[$OPTION]}"
						PARAMETERS="${PARAMETERS} ${USB_DRIVE_SELEC}"
						echo "Selected unit $USB_DRIVE_SELEC"
						KEEP=false
						sleep 1
					else
						echo -e "\n----------------------------"
						echo "Invalid option, press Enter to continue"
						read OPTION
					fi
					;;
			esac
		done
	else

		print-usb-drives-info
		echo "Please connect a USB storage drive and try again"
		proc-exit
	fi
}

install-or-update () {

	KEEP=true	
	while [[ $KEEP == true ]]; do
		
		OPTION=""

		clear

		echo -e "\n----------------------------"
		echo -e "Select an option\n"

		echo -e "I) Install\t\tFail if disk already installed with ventoy"
		echo -e "F) Force install\tNo matter installed or not"
		echo -e "U) Update\t\tDoes not delete files"
		echo -e "C) Cancel\n"

		read OPTION

		case "$OPTION" in
			C|c )
				proc-canceled
				;;
			I|i )
				PARAMETERS="${PARAMETERS} -i"
				echo "Selected «Install»"
				KEEP=false
				sleep 1
				;;
			F|f )
				PARAMETERS="${PARAMETERS} -I"
				echo "Selected «Force install»"
				KEEP=false
				sleep 1
			;;
			U|u )
				PARAMETERS="${PARAMETERS} -u"
				echo "Selected «Update»"
				KEEP=false
				sleep 1
				;;
			* )
				echo -e "\n----------------------------"
				echo "Invalid option, press Enter to continue"
				read OPTION
				;;
		esac
	done
}

select-secure-boot () {

	KEEP=true	
	while [[ $KEEP == true ]]; do
		
		OPTION=""

		clear

		echo -e "\n----------------------------"
		echo -e "Secure Boot for UEFI\n"

		echo "E) Enable"
		echo "D) Disable"
		echo -e "C) Cancel\n"

		read OPTION

		case "$OPTION" in
			C|c )
				proc-canceled
				;;
			E|e )
				PARAMETERS="${PARAMETERS} -s"
				echo "Selected «Enable Secure Boot»"
				KEEP=false
				sleep 1
				;;
			D|d )
				echo "Selected «Disable Secure Boot»"
				KEEP=false
				sleep 1
			;;
			* )
				echo -e "\n----------------------------"
				echo "Invalid option, press Enter to continue"
				read OPTION
				;;
		esac
	done
}

select-partition-table () {

	KEEP=true	
	while [[ $KEEP == true ]]; do
		
		OPTION=""

		clear

		echo -e "\n----------------------------"
		echo -e "Partition table type\n"

		echo "G) GPT"
		echo "M) MBR"
		echo -e "C) Cancel\n"

		read OPTION

		case "$OPTION" in
			C|c )
				proc-canceled
				;;
			G|g )
				PARAMETERS="${PARAMETERS} -g"
				echo "Selected «GPT partition table»"
				KEEP=false
				sleep 1
				;;
			M|m )
				echo "Selected «MBR partition table»"
				KEEP=false
				sleep 1
			;;
			* )
				echo -e "\n----------------------------"
				echo "Invalid option, press Enter to continue"
				read OPTION
				;;
		esac
	done
}

get-usb-drives
install-or-update
#If you did not select update
if [[ $( echo ${PARAMETERS} | grep -v "\-u" ) ]]; then
	select-secure-boot
	select-partition-table
fi
selec-usb-drive

sudo sh /opt/apps/ventoy/Ventoy2Disk.sh "${PARAMETERS}"

proc-exit