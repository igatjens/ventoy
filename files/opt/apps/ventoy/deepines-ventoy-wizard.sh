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
	echo "Presione Enter para terminar"
	read OPTION
	exit 0
}

proc-canceled () {

	echo "Procedimiento cancelado"
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
		echo -e "Unidades de almacenamiento USB\n"
		lsblk -o NAME,LABEL,SIZE,FSTYPE,PATH ${USB_DRIVES[@]}
	else
		echo -e "\n----------------------------"
		echo -e "No hay unidades de almacenamiento USB disponibles\n"
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
			echo "Seleccione una de las unidades USB"

			COUNT=1
			for i in $(print-usb-drives); do
				echo "$COUNT) ${i}"
				let COUNT++
			done
			echo -e "C) Cancelar\n"

			read OPTION

			case "$OPTION" in
				C|c )
					proc-canceled
					;;
				* )
					if [[ $OPTION -ge 1 ]] && [[ $OPTION -le ${#USB_DRIVES[@]} ]]; then

						USB_DRIVE_SELEC="${USB_DRIVES[$OPTION]}"
						PARAMETERS="${PARAMETERS} ${USB_DRIVE_SELEC}"
						echo "Unidad seleccionada $USB_DRIVE_SELEC"
						KEEP=false
						sleep 1
					else
						echo -e "\n----------------------------"
						echo "Opción no válida, presione Enter para continuar"
						read OPTION
					fi
					;;
			esac
		done
	else

		print-usb-drives-info
		echo "Conecte una unidad de almacenamiento USB e inténtelo de nuevo"
		proc-exit
	fi
}

install-or-update () {

	KEEP=true	
	while [[ $KEEP == true ]]; do
		
		OPTION=""

		clear

		echo -e "\n----------------------------"
		echo -e "Seleccione una opción\n"

		echo -e "I) Instalar\t\tFalla si la unidad ya tiene instalado Ventoy"
		echo -e "F) Forzar instalación\tSe instala aún si Ventoy ya está instalado"
		echo -e "A) Actualizar\t\tNo borra los archivos"
		echo -e "C) Cancelar\n"

		read OPTION

		case "$OPTION" in
			C|c )
				proc-canceled
				;;
			I|i )
				PARAMETERS="${PARAMETERS} -i"
				echo "Seleccionado «Instalar»"
				KEEP=false
				sleep 1
				;;
			F|f )
				PARAMETERS="${PARAMETERS} -I"
				echo "Seleccionado «Forzar instalación»"
				KEEP=false
				sleep 1
			;;
			A|a )
				PARAMETERS="${PARAMETERS} -u"
				echo "Seleccionado Actualizar"
				KEEP=false
				sleep 1
				;;
			* )
				echo -e "\n----------------------------"
				echo "Opción no válida, presione Enter para continuar"
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
		echo -e "Secure Boot para UEFI\n"

		echo "A) Activar"
		echo "D) Desactivar"
		echo -e "C) Cancelar\n"

		read OPTION

		case "$OPTION" in
			C|c )
				proc-canceled
				;;
			A|a )
				PARAMETERS="${PARAMETERS} -s"
				echo "Seleccionado «Activar Secure Boot»"
				KEEP=false
				sleep 1
				;;
			D|d )
				echo "Seleccionado «Desactivar Secure Boot»"
				KEEP=false
				sleep 1
			;;
			* )
				echo -e "\n----------------------------"
				echo "Opción no válida, presione Enter para continuar"
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
		echo -e "Tipo de tabla de particiones\n"

		echo "G) GPT"
		echo "M) MBR"
		echo -e "C) Cancelar\n"

		read OPTION

		case "$OPTION" in
			C|c )
				proc-canceled
				;;
			G|g )
				PARAMETERS="${PARAMETERS} -g"
				echo "Seleccionado «Tabla de particiones GPT»"
				KEEP=false
				sleep 1
				;;
			M|m )
				echo "Seleccionado «Tabla de particiones MBR»"
				KEEP=false
				sleep 1
			;;
			* )
				echo -e "\n----------------------------"
				echo "Opción no válida, presione Enter para continuar"
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