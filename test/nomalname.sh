#!/bin/bash
function N_K(){
local IFS="$1"
for fn in $allfilename
do
    newfn=`echo $fn|sed 'y/()[]「」 （）　"“”:|?-/_________________/'`
    echo "From $(echo $fn|sed 's/ /\\ /g') to $newfn"
    mv "$fn" "$newfn"
done
}
allfilename=`ls -F|grep -v '/$'|sed ':a;N;s|\n|/|;ba;'`
[ "$allfilename" != "" ] && N_K "/"
