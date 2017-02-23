##OpenVZ-TCP_BBR-by-Alpine_Linux

在OpenVZ（须TUN/TAP）或者KVM等环境上通过UML（User Mode Linux）方式，实现BBR加速。
已经制作好了Alpine_Linux的镜像，内置shadowsocks-go、supervisor、vi。

============

##简要步骤
首先要制作vmlinux，在debian_8下对于4.9.11内核，可用我的配置。

```shell
apt-get update;apt-get upgrade -y
apt-get install build-essential libncurses5-dev bc screen p7zip p7zip-full
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
然后下载镜像文件，解压还原，大概123MB。

```shell
wget https://github.com/fanyueciyuan/eazy-for-ss/raw/master/openvz-bbr/alpine_bbr_ss.img.7z.001
wget https://github.com/fanyueciyuan/eazy-for-ss/raw/master/openvz-bbr/alpine_bbr_ss.img.7z.002
7z e alpine_bbr_ss.img.7z.001
rm alpine_bbr_ss.img.7z.00*
sha256sum alpine_bbr_ss.img 
4f299f15f67500de55718ce4632681691d9d19de0b371ce9ff5ab0f15ae67c5d 
```

设定tap，开启转发，将9000到19000端口的流量都转发到镜像系统中去。
 
```shell
sudo ip tuntap add tap0 mode tap  
sudo ip addr add 10.0.0.1/24 dev tap0  
sudo ip link set tap0 up  
sudo iptables -P FORWARD ACCEPT  
sudo iptables -t nat -A POSTROUTING  -j MASQUERADE
sudo iptables -t nat -A PREROUTING  -p tcp --dport 9000:19000 -j DNAT --to-destination 10.0.0.2
```

最后开启镜像，
```shell
sudo ./vmlinux root=/dev/ubda ubd0=alpine_bbr_ss.img rw eth0=tuntap,tap0 mem=64m
```

如果需要修改镜像密码，或者修改内置ss配置的话，可以通过screen命令来操作。下面的X，根据具体情况修改。
系统root密码liyangyijie，ss则在9000端口上，rc4-md5，密码同前。
```shell
screen /dev/pts/X
```
