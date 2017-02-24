##OpenVZ-TCP_BBR-by-Alpine_Linux

在OpenVZ（须TUN/TAP）或者KVM等环境上通过UML（User Mode Linux）方式，实现BBR加速。
已经制作好了Alpine_Linux的镜像，内置shadowsocks-go、vi以及开启swap。

============

##简要步骤
首先要制作vmlinux，在debian_8下对于4.9.11内核，可用我的配置。

```shell
apt-get update;apt-get upgrade -y
apt-get install build-essential libncurses5-dev bc screen
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.9.11.tar.xz
tar xf linux-4.9.11.tar.xz
rm linux-4.9.11.tar.xz
cd linux-4.9.11
make defconfig ARCH=um
wget https://raw.githubusercontent.com/fanyueciyuan/eazy-for-ss/master/openvz-bbr/config.bbr_to_.config
mv config.bbr_to_.config .config
make ARCH=um vmlinux 
```

可在linux-4.9.11文件夹下获得vmlinux的可执行文件。
可将其移动到其他文件夹下，方便使用。
然后下载镜像文件，解压还原，大概150MB。

```shell
wget https://github.com/fanyueciyuan/eazy-for-ss/raw/master/openvz-bbr/alpine_bbr_ss_swap.img.gz
gzip -d alpine_bbr_ss_swap.img.gz

sha256sum alpine_bbr_ss_swap.img.gz
e6fa4bb86608eb4c532ad939cacea2f07886f0f9d0c07e7e67d0729ab67e781d
```

设定tap，开启转发，将9000到19000端口的流量都转发到镜像系统中去。
 
```shell
D_I=`ip route show 0/0 | sort -k 7 | head -n 1 | sed -n 's/^default.* dev \([^ ]*\).*/\1/p'`
sudo ip tuntap add tap0 mode tap  
sudo ip addr add 10.0.0.1/24 dev tap0  
sudo ip link set tap0 up  
sudo iptables -P FORWARD ACCEPT
sudo iptables -t nat -A POSTROUTING  -j MASQUERADE
sudo iptables -t nat -A PREROUTING -i ${D_I} -p tcp --dport 9000:19000 -j DNAT --to-destination 10.0.0.2
```

最后开启镜像，
```shell
sudo ./vmlinux root=/dev/ubda ubd0=alpine_bbr_ss_swap.img rw eth0=tuntap,tap0 mem=64m
```

如果需要修改镜像密码，或者修改内置ss配置的话，可以通过screen命令来操作。下面的X，根据具体情况修改。
系统root密码liyangyijie，ss则在9999端口上，rc4-md5，密码同前。
```shell
screen /dev/pts/X
```
