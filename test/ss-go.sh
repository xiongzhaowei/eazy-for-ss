#!/bin/bash
###########################
#Default vars
###########################
[ -f /etc/shadowsocks-go/config.json ] && {
    sed -i s/\'/\"/g /etc/shadowsocks-go/config.json
    d_pwd=`sed -n 's/.*word":"\([^"]*\).*/\1/p' /etc/shadowsocks-go/config.json`
    d_pt=`sed -n 's/.*port":\([^,]*\).*/\1/p' /etc/shadowsocks-go/config.json`
    d_mt=`sed -n 's/.*thod":"\([^"]*\).*/\1/p' /etc/shadowsocks-go/config.json`
}
d_pwd=${d_pwd:-112233}
d_pt=${d_pt:-4000}
d_mt=${d_mt:-chacha20}
shadowsockspwd=${1:-$d_pwd}
shadowsockspt=${2:-$d_pt}
shadowsocksmt=${3:-$d_mt}
###########################
#Main func
###########################
function Check_E {
    [ $EUID -ne 0 ] && {
        echo "Error:This script must be run as root!"
        exit 1
    }
    [ ! -f /etc/debian_version ] && {
    echo "Looks like you aren't running this installer on a Debian-based system."
    exit 1
    }
}
function Set_Sysctl {
    /sbin/modprobe tcp_hybla > /dev/null 2>&1
    sysctl net.ipv4.tcp_available_congestion_control | grep 'hybla' > /dev/null 2>&1
    if [ $? -eq 0 ]; then 
        tcp_congestion_ss="hybla"
    else
        tcp_congestion_ss="cubic"
    fi
    cat > /etc/sysctl.d/local_ss.conf<<EOF
fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 65536
net.core.wmem_default = 65536
net.core.netdev_max_backlog = 4096
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = $tcp_congestion_ss
EOF
    sysctl -p /etc/sysctl.d/local_ss.conf
}
function Dependence_Install {
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q gzip sudo nano sed vim gawk curl dnsutils apt-transport-https net-tools supervisor
}
function Upgrade_SS {
    Latest_Version=`wget -qO- dl.chenyufei.info/shadowsocks/latest/|grep 'server.*x64'|sed 's|.*-\(.*\)\.gz</a>.*|\1|'`
#uname -m|grep 64
    if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        wget -c http://dl.chenyufei.info/shadowsocks/latest/shadowsocks-server-linux64-$Latest_Version.gz
        gzip -d shadowsocks-server-linux64-$Latest_Version.gz
        mv -f shadowsocks-server-linux64-$Latest_Version /usr/bin/ss-goserver
    else
        wget -c http://dl.chenyufei.info/shadowsocks/latest/shadowsocks-server-linux32-$Latest_Version.gz
        gzip -d shadowsocks-server-linux32-$Latest_Version.gz
        mv -f shadowsocks-server-linux32-$Latest_Version /usr/bin/ss-goserver
    fi
    strip -s /usr/bin/ss-goserver
    chmod +x /usr/bin/ss-goserver
}
function Set_Supervisor {
    cat > /etc/supervisor/conf.d/shadowsocks-go.conf<<'EOF'
[program:shadowsocks-go]
command=/usr/bin/ss-goserver -c /etc/shadowsocks-go/config.json
autostart=true
autorestart=true
user=nobody
EOF
    echo 'ulimit -n 51200' >> /etc/default/supervisor
}
function Show_Result {
    IP=$(wget -qO- ipv4.icanhazip.com)
    if [ $? -ne 0 -o -z $IP ]; then
        IP=`dig +short +tcp myip.opendns.com @resolver1.opendns.com`
    fi
    ps axc|grep 'ss-goserver' > /dev/null 2>&1
    if [ $? -eq 0 ]; then 
        clear
        echo 
        echo "Congratulations!"
        echo "Shadowsocks-go start success!"
        echo
        echo -e "Your Server IP:\t\t\033[41;37m ${IP} \033[0m"
        echo -e "Your Server Port:\t\033[41;37m ${shadowsockspt} \033[0m"
        echo -e "Your Password:\t\t\033[41;37m ${shadowsockspwd} \033[0m"
        echo -e "Your Encryption Method:\t\033[41;37m ${shadowsocksmt} \033[0m"
        echo 
        echo "Enjoy it!"
        echo 
        exit 0
    else
        echo "Shadowsocks-go start failure!"
        exit 1
    fi
}
function Change_Profiles {
    [ ! -d /etc/shadowsocks-go ] && mkdir /etc/shadowsocks-go
    cat > /etc/shadowsocks-go/config.json<<EOF
{
    "server":"0.0.0.0",
    "server_port":${shadowsockspt},
    "password":"${shadowsockspwd}",
    "method":"${shadowsocksmt}",
    "timeout":600
}
EOF
     supervisorctl reload
     sleep 1
     Show_Result
}
###########################
#Main
###########################
[ -x /usr/bin/ss-goserver ] && {
    [ "$1" = "" ] && {
        [ "$2" = "" ] && {
            [ "$3" = "" ] && {
                Upgrade_SS && exit 0
            }
        }
    }
    Change_Profiles && exit 0
}
Check_E
Dependence_Install
Set_Sysctl
Upgrade_SS
Set_Supervisor
Change_Profiles
:
