#!/bin/sh

mdadm --zero-superblock /dev/sd{b,c,d,e,f,g,h} 2> /dev/null
mdadm --create /dev/md0 --level=5 --raid-devices=7 /dev/sd{b,c,d,e,f,g,h}
echo "DEVICE partitions" > /etc/mdadm.conf
mdadm --detail --brief /dev/md0 >> /etc/mdadm.conf
