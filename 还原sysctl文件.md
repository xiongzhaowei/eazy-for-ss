有些优化ss教程会出示如下命令行

```
rm -f /sbin/sysctl
ln -s /bin/true /sbin/sysctl
rm -f /sbin/modprobe
ln -s /bin/true /sbin/modprobe
```

其实是把 `sysctl` 和 `modprobe软连` 都~~删掉~~了。   :fearful:


==
How to restore the two files？

- For modprobe 
```
ln -sf /bin/kmod /sbin/modprobe
```
- For sysctl
  -  For centos
  ```
  yum reinstall procps
  ```
  - For debian 
  ```  
  apt-get install procps --reinstall
 ```
