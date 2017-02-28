##SHM
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
