#!/bin/bash
function N_K(){
IFS="$1"
for fn in $allfilename
do
    newfn=`echo $fn|sed 'y/()[]「」 （）　"“”:|?/----------------/'|sed 's/^-*//'`
    echo "From $fn to $newfn"
    mv "$fn" "$newfn"
done
}
allfilename=`ls -F|grep -v '/$'|sed ':a;N;s/\n/|/;ba;'`
