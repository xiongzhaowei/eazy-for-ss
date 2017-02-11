#!/bin/bash
#https://cipherli.st/
#https://www.futures.moe/writings/configure-nginx-with-security-and-effective-yes-or-no.htm
#https://guts.me/2015/06/15/enable-chacha20-poly1305-on-nginx/
#https://github.com/cloudflare/sslconfig/blob/master/conf
#https://neveta.com/technote/use-cloudflare-openssl-patch-support-chacha20.html
#curl -I http://www.yoursite.com
#libressl和Nginx版本
#LibreSSL_V=`wget -qO- http://www.libressl.org/ |sed -n 's/.*stable release is \([^<]*\).*/\1/p'`
#Nginx_V=`wget -qO- 'http://nginx.org/en/CHANGES'|sed -n 's/^Changes.*nx \([^ ]*\).*/\1/p'|head -n1`
LibreSSL_V=2.5.1
Nginx_V=1.11.9
#######################
#base-func
die(){ echo -e "\033[33mERROR: $1 \033[0m" > /dev/null 1>&2;exit 1;};print_info(){ echo -n -e '\e[1;36m';echo -n $1;echo -e '\e[0m';};print_warn(){ echo -n -e '\033[41;37m';echo -n $1;echo -e '\033[0m';};Script_Dir="$(cd "$(dirname $0)"; pwd)"
########################
#main
#测试环境
[ $EUID -ne 0 ] && die 'Must be run by root user.'
print_info "Root ok"
[ ! -f /etc/debian_version ] && die "Must be run on a Debian-based system."
print_info "Debian-based ok"
Systemd="n" && Nginx_DEB="n"
pgrep systemd-journal > /dev/null 2>&1 && Systemd="y"
print_info "Systemd status : $Systemd"
[ -e /etc/init.d/nginx ] && Nginx_DEB="y"
print_info "Nginx status : $Nginx_DEB"
mkdir -p /var/www/html > /dev/null 2>&1
mkdir -p /var/{lib,log}/nginx > /dev/null 2>&1
mkdir -p /etc/nginx/{conf.d,sites-enabled} > /dev/null 2>&1
mkdir -p /home/cache/{temp,path} > /dev/null 2>&1
[ "$Nginx_DEB" = "y" ] && {
    Installed_Nginx=$(echo `dpkg --get-selections | grep nginx` | sed 's/ hold//g;s/ install//g')
    for I_N in $Installed_Nginx
    do
        echo $I_N hold | dpkg --set-selections > /dev/null 2>&1
    done
}
#更新安装依赖
apt-get update
apt-get install -y tar unzip build-essential openssl git sudo
apt-get install -y zlib1g-dev libbz2-dev libpcre3 libpcre3-dev libssl-dev libperl-dev libxslt1-dev libgd2-xpm-dev libgeoip-dev libpam0g-dev libc6-dev
apt-get install -y libc6 libgeoip1 libxslt1.1 libxml2 libexpat1 libossp-uuid16
apt-get install -y libgd2-xpm
apt-get install -y libgd2-xpm-dev
apt-get clean
#添加用户修改权限
cat /etc/group|grep -E '^www-data:'  > /dev/null 2>&1 || sudo groupadd www-data
cat /etc/shadow|grep -E '^www-data:'  > /dev/null 2>&1 || sudo useradd -s /sbin/nologin -g www-data www-data
chown -R www-data:www-data /home/cache
chown -R www-data:www-data /var/www
#编译安装
mkdir -p NGINX/{libressl,Nginx}
cd NGINX
wget -c http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LibreSSL_V}.tar.gz
wget -c http://nginx.org/download/nginx-${Nginx_V}.tar.gz
tar xf libressl-${LibreSSL_V}.tar.gz -C libressl --strip-components=1
tar xf nginx-${Nginx_V}.tar.gz -C Nginx --strip-components=1
git clone https://github.com/stogh/ngx_http_auth_pam_module.git
#git clone https://github.com/gnosek/nginx-upstream-fair.git
git clone https://github.com/itoffshore/nginx-upstream-fair.git
git clone https://github.com/cuber/ngx_http_google_filter_module.git
git clone https://github.com/arut/nginx-dav-ext-module.git
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git
cd Nginx
./configure --user=www-data --group=www-data --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-ipv6 --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_gunzip_module --with-file-aio --with-threads --with-http_v2_module --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_secure_link_module --with-http_sub_module --with-http_xslt_module --with-mail --with-mail_ssl_module \
--add-module=../ngx_http_google_filter_module \
--add-module=../ngx_http_substitutions_filter_module \
--add-module=../ngx_http_auth_pam_module \
--add-module=../nginx-upstream-fair \
--add-module=../nginx-dav-ext-module \
--with-openssl=../libressl \
--with-ld-opt="-lrt"
make -j"$(nproc)"
strip -s objs/nginx || die "Make Failed."
[ "$Nginx_DEB" = "y" ] && {
    /etc/init.d/nginx stop
    sleep 2
    mv -T /usr/sbin/nginx  /usr/sbin/nginx_old_$(date +%s)
} || {
    wget -c --no-check-certificate https://raw.githubusercontent.com/fanyueciyuan/eazy-for-ss/master/nginx/nginx -O /etc/init.d/nginx
    chmod 755 /etc/init.d/nginx
    print_info "Enable nginx service to start during bootup."
    [ "$Systemd" = "y" ] && {
#sudo update-rc.d nginx defaults;sudo update-rc.d -f nginx remove
        systemctl enable nginx > /dev/null 2>&1 || sudo update-rc.d nginx defaults > /dev/null 2>&1
    } || sudo update-rc.d nginx defaults > /dev/null 2>&1
}
[ -f /etc/nginx/nginx.conf ] && mv -T /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
wget -c --no-check-certificate https://raw.githubusercontent.com/fanyueciyuan/eazy-for-ss/master/nginx/nginx.conf -O /etc/nginx/nginx.conf
make install
[ -f /etc/nginx/conf.d/nginx-google.conf ] || wget -c --no-check-certificate https://raw.githubusercontent.com/fanyueciyuan/eazy-for-ss/master/nginx/nginx-google.conf -O /etc/nginx/conf.d/nginx-google.conf
#sed -i 's/^/#/' /etc/nginx/conf.d/nginx-google.conf
cd $Script_Dir
print_warn "Edit /etc/nginx/conf.d/nginx-google.conf "
exit 0
