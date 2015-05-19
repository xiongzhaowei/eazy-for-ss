#!/bin/bash
###############
#vars begin
API=""
DOC_NAME="Optimized"
#vars end
###############
###############
#main begin
function N_K(){
    local IFS='/'
    for fn in $KG
    do
        newfn=`echo $fn|sed 'y/ -/__/'`
        echo "From $(echo $fn|sed 's/ /\\ /g') to $newfn"
        mv "$fn" "$newfn"
    done
}
function UP_FILE(){
    AllFiles=$(ls|egrep '.*\.(png|jpg|jpeg)$')
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
}
Script_Dir="$(cd "$(dirname $0)"; pwd)"
Front="${Script_Dir}/${DOC_NAME}"
[ ! -d $Front ] && mkdir $Front
KG=$(ls|egrep '.*\.(png|jpg|jpeg)$'|grep ' '|sed ':a;N;s|\n|/|;ba;')
[ "$KG" != "" ] && N_K
UP_FILE
#main end
###############
exit 0
