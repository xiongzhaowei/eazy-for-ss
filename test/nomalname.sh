#!/bin/bash
allfilename=`ls -F|grep -v '/$'|sed ':a;N;s/\n/|/;ba;'`
IFS='|'
for fn in $allfilename
do
    newfn=`echo $fn|sed 'y/()[]「」 （）　"“”/-------------/'|sed 's/^-*//'`
    echo "From $fn to $newfn"
    mv "$fn" "$newfn"
done
