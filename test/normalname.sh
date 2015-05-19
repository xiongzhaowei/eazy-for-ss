#!/bin/bash
function N_K(){
local IFS="$1"
for fn in $allfilename
do
    newfn=`echo $fn|sed 'y/()[]「」 （）　"“”:|?-/_________________/'`
    [ "$fn" != "$newfn" ] && {
        echo "From [ $fn ] To [ $newfn ]"
        mv "$fn" "$newfn"
    }
done
}
allfilename=`ls -F|grep -v '/$'|sed ':a;N;s|\n|/|;ba;'`
[ "$allfilename" != "" ] && N_K "/"
