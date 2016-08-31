#!/usr/bin/env bash
#vars
#########################################################
My_Domain=
UserName=
PassWord=
Set_Port=
#########################################################
Mycer_PATH="${HOME}/.acme.sh/${My_Domain}/fullchain.cer"
Mykey_PATH="${HOME}/.acme.sh/${My_Domain}/${My_Domain}.key"
Port=${Set_Port:-443}
#install dep
apt-get install --no-install-recommends -y wget cron netcat curl sudo openssl \
ca-certificates bash-completion git supervisor
#install le
wget - https://get.acme.sh | sh
. ~/.profile
#get cer(The tcp 443 port MUST be free to listen)
acme.sh --issue --tls -d ${My_Domain}
# get govps
GV=`curl -sL https://github.com/phuslu/goproxy/releases |sed -n 's/.*<t.*vps.*-\([^<]*\)\.t.*/\1/p'`
wget --no-check-certificate -c https://github.com/phuslu/goproxy/releases/download/goproxy/goproxy-vps_linux_amd64-${GV}.tar.bz2 -O /opt/govpsx64.tar.bz2
cd /opt
tar xf govpsx64.tar.bz2
chmod +x govps
#daemon by supervisor
cat > /etc/supervisor/conf.d/govps.conf<< EOF
[program:govps]
command=/opt/govps -addr=":${Port}" -auth="${UserName}:${PassWord}" -certfile="${Mycer_PATH}" -keyfile="${Mykey_PATH}"
autostart=true
autorestart=true
user=root
EOF
/etc/init.d/supervisor stop
sleep 1
/etc/init.d/supervisor start
supervisorctl reload
