#!/bin/bash
allfilename=`echo *`
for fn in $allfilename
do
    newfn=`echo $fn|sed 'y/()[]「」 （）　"“”/-------------/'|sed 's/^-//`
    echo "From $fn to $newfn"
    mv $fn $newfn
done
