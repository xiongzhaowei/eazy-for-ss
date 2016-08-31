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
wget -O - https://get.acme.sh | sh
. ~/.profile
#get cer(The tcp 443 port MUST be free to listen)
acme.sh --issue --tls -d ${My_Domain}
# get govps
mkdir -p /opt/goproxy-vps
GV=`curl -sL https://github.com/phuslu/goproxy/releases |sed -n 's/.*<t.*vps.*-\([^<]*\)\.t.*/\1/p'`
wget --no-check-certificate -c https://github.com/phuslu/goproxy/releases/download/goproxy/goproxy-vps_linux_amd64-${GV}.tar.bz2 -O /opt/goproxy-vps/govpsx64.tar.bz2
cd /opt/goproxy-vps
tar xf govpsx64.tar.bz2
chmod +x goproxy-vps
#daemon by supervisor
cat > /etc/supervisor/conf.d/govps.conf<< EOF
[program:govps]
command=/opt/goproxy-vps/goproxy-vps -addr=":${Port}" -auth="${UserName}:${PassWord}" -certfile="${Mycer_PATH}" -keyfile="${Mykey_PATH}"
autostart=true
autorestart=true
user=root
EOF

/etc/init.d/supervisor stop
sleep 1
/etc/init.d/supervisor start
supervisorctl reload
