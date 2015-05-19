#!/bin/bash

###############
#vars begin
API=""
DOC_NAME="Optimized"
#vars end
###############

###############
#main begin
Script_Dir="$(cd "$(dirname $0)"; pwd)"
Front="${Script_Dir}/${DOC_NAME}"
[ ! -d $Front ] && mkdir $Front
AllFiles=`ls|egrep '.*\.(png|jpg|jpeg)$'`
for FileName in ${AllFiles}
do
echo "Optimize ${FileName}"
JSON=`curl -si --user api:${API} --data-binary @${FileName} https://api.tinypng.com/shrink`
FileAdd=`echo $JSON|sed -n 's/.*"url":"\([^"]*\).*/\1/p'`
[ "$FileAdd" = "" ] && echo "Optimize ${FileName} failure!"
[ "$FileAdd" != "" ] && {
wget $FileAdd --no-check-certificate -qO ${Front}/${FileName}
echo "You could get Optimized version From ${Front}/${FileName}"
}
done
#main end
###############
exit 0
