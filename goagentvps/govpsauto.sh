#!/usr/bin/env bash
#vars
#########################################################
My_Domain=
UserName=
PassWord=
Set_Port=
#########################################################
User_PATH=$(cd ~ ; echo `pwd`)
Mycer_PATH="${User_PATH}/.le/${My_Domain}/${My_Domain}.cer"
Mykey_PATH="${User_PATH}/.le/${My_Domain}/${My_Domain}.key"
Port=${Set_Port:-443}
#install dep
apt-get install --no-install-recommends -y wegt cron netcat curl sudo openssl \
ca-certificates bash-completion git supervisor
#install le
cd ~
git clone https://github.com/Neilpang/le.git
cd le
chmod +x le.sh
./le.sh install
sleep 1
./le.sh install
. ~/.profile
cd ..
rm -rf le
#get cer
~/.le/le.sh issue no ${My_Domain}
# get govps
wget --no-check-certificate -c https://github.com/fanyueciyuan/eazy-for-ss/raw/master/goagentvps/govpsx64.tar.xz -O /opt/govpsx64.tar.xz
cd /opt
tar xf govpsx64.tar.xz
chmod +x govps
#daemon by supervisor
cat > /etc/supervisor/conf.d/govps.conf<< EOF
[program:govps]
command=/opt/govps -addr=":${Port}" -auth="${UserName}:${PassWord}" -certFile="${Mycer_PATH}" -keyFile="${Mykey_PATH}"
autostart=true
autorestart=true
user=root
EOF

/etc/init.d/supervisor stop
sleep 1
/etc/init.d/supervisor start
