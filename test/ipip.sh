#!/bin/bash
function Ip_Check(){
    local IP_TMP="$1"
    if ( echo "$IP_TMP"|egrep -q \
    '^((2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)\.){3}(2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)$' )
    then
        return 0
    else
        return 1
    fi
}
MI="$1"
Ip_Check "$MI" || MI=`curl -sL www.ipip.net|sed -n 's|<.*IP：\([^<]*\).*|\1|p'`
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
