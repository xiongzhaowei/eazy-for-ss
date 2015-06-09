#!/bin/bash
#base-func
die(){ echo -e "\033[33mERROR: $1 \033[0m" > /dev/null 1>&2;exit 1;};print_info(){ echo -n -e '\e[1;36m';echo -n $1;echo -e '\e[0m';};print_xxxx(){ xXxX="#############################";echo;echo "$xXxX$xXxX$xXxX$xXxX";echo;};print_warn(){ echo -n -e '\033[41;37m';echo -n $1;echo -e '\033[0m';};get_random_word(){ D_Num_Random="8";Num_Random=${1:-$D_Num_Random};str=`cat /dev/urandom | tr -cd abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789 | head -c $Num_Random`;echo $str;};Default_Ask(){ echo;Temp_question=$1;Temp_default_var=$2;Temp_var_name=$3;if [  -f ${CONFIG_PATH_VARS} ];then New_temp_default_var=`cat $CONFIG_PATH_VARS | grep "^$Temp_var_name=" | cut -d "'" -f 2`;Temp_default_var=${New_temp_default_var:-$Temp_default_var};fi;echo -e -n "\e[1;36m$Temp_question\e[0m""\033[31m(Default:$Temp_default_var)\033[0m";echo;read Temp_var;if [ "$Temp_default_var" = "y" ] || [ "$Temp_default_var" = "n" ];then Temp_var=$(echo $Temp_var | sed 'y/YESNO0/yesnoo/');case $Temp_var in y|ye|yes) Temp_var=y; ;; n|no) Temp_var=n; ;; *) Temp_var=$Temp_default_var; ;; esac;else Temp_var=${Temp_var:-$Temp_default_var};fi;Temp_cmd="$Temp_var_name='$Temp_var'";eval $Temp_cmd;print_info "Your answer is : ${Temp_var}";echo;print_xxxx;};press_any_key(){ echo;print_info "Press any key to start...or Press Ctrl+C to cancel";get_char_ffff(){ SAVEDSTTY=`stty -g`;stty -echo;stty cbreak;dd if=/dev/tty bs=1 count=1 2> /dev/null;stty -raw;stty echo;stty $SAVEDSTTY;};get_char_fffff=`get_char_ffff`;echo;};Script_Dir="$(cd "$(dirname $0)"; pwd)";
#main
[ $EUID -ne 0 ] && die 'Must be run by root user.'
[ ! -f /etc/debian_version ] && die "Must be run on a Debian-based system."
Default_Ask "Input your username." "$(get_random_word 8)" "username"
Default_Ask "Input your password." "$(get_random_word 8)" "password"
press_any_key
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install python-dev python-gevent python-setuptools python-openssl
easy_install dnslib
easy_install pycrypto
#https://github.com/goagent/goagent/blob/3.0/server/uploadvps.py 44-68行
NET_URL="https://raw.githubusercontent.com/goagent/goagent/3.0"
mkdir -p /opt/goagent/{vps,log}
cd /opt/goagent/vps
wget --no-check-certificate -c $NET_URL/local/proxylib.py
wget --no-check-certificate -c $NET_URL/server/vps/goagentvps.py
wget --no-check-certificate -c $NET_URL/server/vps/supervisor-3.1.3.egg
wget --no-check-certificate -c $NET_URL/server/vps/supervisord-goagentvps.conf
wget --no-check-certificate -c $NET_URL/server/vps/limits.conf
wget --no-check-certificate -c $NET_URL/server/vps/sysctl.conf
wget --no-check-certificate -c $NET_URL/server/vps/goagentvps.sh
ln -sf /opt/goagent/vps/goagentvps.sh /etc/init.d/goagentvps
chmod +x /opt/goagent/vps/goagentvps.sh
mv /etc/sysctl.conf ./sysctl.conf_og
mv /etc/security/limits.conf ./limits.conf_og
#https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks
#禁用tw_recycle
sed -i 's/net.ipv4.tcp_tw_recycle.*/#&/' sysctl.conf
cp -f /opt/goagent/vps/sysctl.conf /etc/
cp -f /opt/goagent/vps/limits.conf /etc/security/
echo "$username $password" >> goagentvps.conf
sysctl -p
pgrep systemd-journal > /dev/null 2>&1 || {
which update-rc.d && update-rc.d goagentvps defaults
which chkconfig && chkconfig goagentvps on
}
pgrep systemd-journal > /dev/null 2>&1 && {
systemctl daemon-reload
systemctl enable goagentvps.service > /dev/null 2>&1
}
service goagentvps stop
service goagentvps start
