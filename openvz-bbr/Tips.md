##SHM BUG
```
Checking that ptrace can change system call numbers...OK
Checking syscall emulation patch for ptrace...OK
Checking advanced syscall emulation patch for ptrace...OK
Checking for tmpfs mount on /dev/shm...OK
Checking PROT_EXEC mmap in /dev/shm/...failed: Operation not permitted
/dev/shm/ must be not mounted noexec
/dev/shm/ is tmpfs and is mounted noexec
```
在宿主机的/etc/fstab 额外加一行如下
```
shm    /dev/shm        tmpfs    nodev,nosuid                0       0 
```

===

##CONFIG
```
UML-specific options 
    ==> [*] Force a static link 
Device Drivers
    ==> [*] Network device support
        ==> <*> Universal TUN/TAP device driver support
[*] Networking support
    ==> Networking options
        ==> [*] IP: TCP syncookie support
        ==> [*] TCP: advanced congestion control
            ==> <*> BBR TCP
            ==> <*> Default TCP congestion control (BBR)
        ==> [*] QoS and/or fair queueing
            ==> <*> Quick Fair Queueing scheduler (QFQ)
            ==> <*> Controlled Delay AQM (CODEL)
            ==> <*> Fair Queue Controlled Delay AQM (FQ_CODEL)
            ==> <*> Fair Queue
```

===

