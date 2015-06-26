#!/bin/bash
MI=""
MI="$1"
[ "$MI" = "" ] && MI=`wget -qO- ipip.net|sed -n 's|<.*IP：\([^<]*\).*|\1|p'`
MI=$(echo $MI)
Ip_Info=`wget -qO- freeapi.ipip.net/$MI`
Ia=`echo $Ip_Info|cut -d'"' -f2`
Ib=`echo $Ip_Info|cut -d'"' -f4`
Ic=`echo $Ip_Info|cut -d'"' -f6`
Id=`echo $Ip_Info|cut -d'"' -f8`
Ie=`echo $Ip_Info|cut -d'"' -f10`
#
IFS=";"
ALL="$Ib;$Ic"
for ii in $ALL
do
[ "$ii" != "" ] && Ia="$Ia-$ii"
done
#
[ "$Ie" = "" ] && Ie="None"
Ie=`echo $Ie|sed 's|\\\/|-|g'`
clear
echo
echo
echo -ne '\e[1;36m'
echo -e "IP:  \t$MI"
echo -e "LOC: \t$Ia"
echo -e "ISP: \t$Ie"
echo -ne '\e[0m'
echo
echo
