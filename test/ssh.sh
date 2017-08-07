#!/bin/bash
#vim -> :set ff=unix
#base-function
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
function die {
    echo -e "\033[33mERROR: $1 \033[0m" > /dev/null 1>&2
    exit 1
}
ROOT_DIR="$(cd "$(dirname $0)"; pwd)"
#vars
VPS_PORT=""
#chmod 600 identity
VPS_KEY_PATH="${ROOT_DIR}/identity"
VPS_USER="root"
VPS_IP="$1"
#My VPS IP list
[ "${VPS_IP}" = "h" ] && VPS_IP=""
[ "${VPS_IP}" = "c" ] && VPS_IP=""

#
Ip_Check "$VPS_IP" || die "Must be IP!"

ssh -i "${VPS_KEY_PATH}" -p "${VPS_PORT}" "${VPS_USER}"@"${VPS_IP}"
