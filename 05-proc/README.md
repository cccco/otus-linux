* [ps-ax.sh](ps-ax.sh) - скрипт вывода процессов в стиле ps ax, не требует для работы root привилегий
* [lsof.sh](lsof.sh) - скрипт поиска открытых файлов или каталогов (lsof), принимает один параметр

ps-ax.sh 


Пример вывода скрипта ps-ax.sh:
    [vagrant@bash vagrant]$ ./ps-ax.sh 
    PID TTY      STAT   TIME COMMAND
    1 ?        Ss     0:01 /usr/lib/systemd/systemd --switched-root --system --deserialize 22 
    2 ?        S      0:00 [kthreadd]
    3 ?        S      0:00 [ksoftirqd/0]
    4 ?        S      0:00 [kworker/0:0]
    5 ?        S<     0:00 [kworker/0:0H]
    6 ?        S      0:00 [kworker/u2:0]
    7 ?        S      0:00 [migration/0]
    8 ?        S      0:00 [rcu_bh]
    9 ?        R      0:00 [rcu_sched]
    10 ?        S<     0:00 [lru-add-drain]
    11 ?        S      0:00 [watchdog/0]
    13 ?        S      0:00 [kdevtmpfs]
    14 ?        S<     0:00 [netns]
    15 ?        S      0:00 [khungtaskd]
    16 ?        S<     0:00 [writeback]
    17 ?        S<     0:00 [kintegrityd]
    18 ?        S<     0:00 [bioset]
    19 ?        S<     0:00 [kblockd]
    20 ?        S<     0:00 [md]
    21 ?        S<     0:00 [edac-poller]
    22 ?        S      0:00 [kworker/0:1]
    23 ?        S      0:00 [kworker/u2:1]
    30 ?        S      0:00 [kswapd0]
    31 ?        SN     0:00 [ksmd]
    32 ?        SN     0:00 [khugepaged]
    33 ?        S<     0:00 [crypto]
    41 ?        S<     0:00 [kthrotld]
    42 ?        S<     0:00 [kmpath_rdacd]
    43 ?        S<     0:00 [kaluad]
    44 ?        S<     0:00 [kpsmoused]
    45 ?        S<     0:00 [ipv6_addrconf]
    46 ?        S      0:00 [kworker/0:2]
    59 ?        S<     0:00 [deferwq]
    90 ?        S      0:00 [kworker/0:3]
    91 ?        S      0:00 [kauditd]
    231 ?        S<     0:00 [ata_sff]
    235 ?        S      0:00 [scsi_eh_0]
    238 ?        S<     0:00 [scsi_tmf_0]
    239 ?        S      0:00 [scsi_eh_1]
    241 ?        S<     0:00 [scsi_tmf_1]
    243 ?        S      0:00 [kworker/u2:2]
    244 ?        S      0:00 [kworker/u2:3]
    309 ?        S<     0:00 [kdmflush]
    310 ?        S<     0:00 [bioset]
    320 ?        S<     0:00 [kdmflush]
    321 ?        S<     0:00 [bioset]
    333 ?        S<     0:00 [bioset]
    334 ?        S<     0:00 [xfsalloc]
    335 ?        S<     0:00 [xfs_mru_cache]
    336 ?        S<     0:00 [xfs-buf/dm-0]
    337 ?        S<     0:00 [xfs-data/dm-0]
    338 ?        S<     0:00 [xfs-conv/dm-0]
    339 ?        S<     0:00 [xfs-cil/dm-0]
    340 ?        S<     0:00 [xfs-reclaim/dm-]
    341 ?        S<     0:00 [xfs-log/dm-0]
    342 ?        S<     0:00 [xfs-eofblocks/d]
    343 ?        S      0:00 [xfsaild/dm-0]
    344 ?        S<     0:00 [kworker/0:1H]
    397 ?        Ss     0:00 /usr/lib/systemd/systemd-journald 
    411 ?        Ss     0:00 /usr/sbin/lvmetad -f 
    427 ?        Ss     0:00 /usr/lib/systemd/systemd-udevd 
    496 ?        S<     0:00 [xfs-buf/sda2]
    498 ?        S<     0:00 [xfs-data/sda2]
    499 ?        S<     0:00 [xfs-conv/sda2]
    504 ?        S<     0:00 [xfs-cil/sda2]
    505 ?        S<     0:00 [xfs-reclaim/sda]
    506 ?        S<     0:00 [xfs-log/sda2]
    507 ?        S<     0:00 [xfs-eofblocks/s]
    508 ?        S      0:00 [xfsaild/sda2]
    527 ?        S<sl   0:00 /sbin/auditd 
    531 ?        S<     0:00 [rpciod]
    532 ?        S<     0:00 [xprtiod]
    552 ?        Ssl    0:00 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation 
    553 ?        Ss     0:00 /sbin/rpcbind -w 
    560 ?        Ssl    0:00 /usr/lib/polkit-1/polkitd --no-debug 
    561 ?        Ss     0:00 /usr/lib/systemd/systemd-logind 
    567 ?        S      0:00 /usr/sbin/chronyd 
    572 ?        Ssl    0:00 /usr/sbin/gssproxy -D 
    595 ?        Ss     0:00 /usr/sbin/crond -n 
    600 tty1     Ss+    0:00 /sbin/agetty --noclear tty1 linux 
    861 ?        Ssl    0:00 /usr/bin/python -Es /usr/sbin/tuned -l -P 
    863 ?        Ss     0:00 /usr/sbin/sshd -D -u0 
    864 ?        Ssl    0:00 /usr/sbin/rsyslogd -n 
    1079 ?        Ss     0:00 /usr/libexec/postfix/master -w 
    1096 ?        S      0:00 pickup -l -t unix -u 
    1097 ?        S      0:00 qmgr -l -t unix -u 
    3115 ?        Ssl    0:00 /usr/sbin/NetworkManager --no-daemon 
    3131 ?        S      0:00 /sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf /var/run/dhclient-eth0.pid -lf /var/lib/NetworkManager/dhclient-5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03-eth0.
    3836 ?        Ss     0:00 sshd: vagrant [priv]     
    3839 ?        S      0:00 sshd: vagrant@pts/0      
    3840 pts/0    Ss+    0:00 -bash 
    3879 pts/0    S+     0:00 bash ./ps-ax.sh 
    3881 ?        S      0:00 bash ./ps-ax.sh 
    3882 ?        S      0:00 bash ./ps-ax.sh 
    3883 ?        S      0:00 bash ./ps-ax.sh 


Пример вывода скрипта lsof.sh для поиска каталога:
    root@bash vagrant]# ./lsof.sh /vagrant
    COMMAND     PID       USER   FD   TYPE DEVICE SIZE/OFF   NODE NAME                          
    bash       3050    vagrant  cwd    DIR  253,0       56 369967 /vagrant                      
    sudo       4585       root  cwd    DIR  253,0       56 369967 /vagrant                      
    bash       4587       root  cwd    DIR  253,0       56 369967 /vagrant                      
    bash      23283       root  cwd    DIR  253,0       56 369967 /vagrant

Пример вывода скрипта lsof.sh для поиска файла:
    [root@bash vagrant]# ./lsof.sh /dev/pts/0
    COMMAND     PID       USER   FD   TYPE DEVICE SIZE/OFF   NODE NAME                          
    bash       3050    vagrant   0u    REG   0,12        0      3 /dev/pts/0                    
    bash       3050    vagrant   1u    REG   0,12        0      3 /dev/pts/0                    
    bash       3050    vagrant   2u    REG   0,12        0      3 /dev/pts/0                    
    bash       3050    vagrant 255u    REG   0,12        0      3 /dev/pts/0                    
    sudo       4585       root   0u    REG   0,12        0      3 /dev/pts/0                    
    sudo       4585       root   1u    REG   0,12        0      3 /dev/pts/0                    
    sudo       4585       root   2u    REG   0,12        0      3 /dev/pts/0                    
    su         4586       root   0u    REG   0,12        0      3 /dev/pts/0                    
    su         4586       root   1u    REG   0,12        0      3 /dev/pts/0                    
    su         4586       root   2u    REG   0,12        0      3 /dev/pts/0                    
    bash       4587       root   0u    REG   0,12        0      3 /dev/pts/0                    
    bash       4587       root   1u    REG   0,12        0      3 /dev/pts/0                    
    bash       4587       root   2u    REG   0,12        0      3 /dev/pts/0                    
    bash       4587       root 255u    REG   0,12        0      3 /dev/pts/0                    
    mc        22138       root   0u    REG   0,12        0      3 /dev/pts/0                    
    mc        22138       root   1u    REG   0,12        0      3 /dev/pts/0                    
    mc        22138       root   2u    REG   0,12        0      3 /dev/pts/0 
