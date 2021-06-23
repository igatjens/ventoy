#! /bin/bash

#*******************************************************************
#
#	Ventoy Web for Deepin
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

DISTRIBUTION=$(lsb_release -i | cut -f2)

#If the distribution is Deepin
if [[ $DISTRIBUTION == "Deepin" ]]; then
	
	sudo sh /opt/apps/ventoy/VentoyWebDeepin.sh
else
	
	xdg-open http://127.0.0.1:24680
	sudo sh /opt/apps/ventoy/VentoyWeb.sh 
fi
