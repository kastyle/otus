#!/bin/bash
#Без sudo практически при всех действиях ошибка - отказано в доступе.

sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}
sudo  mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}
sudo mkdir  /etc/mdadm
echo "DEVICE partitions" | sudo tee -a  /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf

sudo  parted -s /dev/md0 mklabel gpt
sudo parted /dev/md0 mkpart primary ext4 0% 20%
sudo parted /dev/md0 mkpart primary ext4 20% 40%
sudo parted /dev/md0 mkpart primary ext4 40% 60%
sudo parted /dev/md0 mkpart primary ext4 60% 80%
sudo parted /dev/md0 mkpart primary ext4 80% 100%

sudo mkfs.ext4 /dev/md0p1
sudo mkfs.ext4 /dev/md0p2
sudo mkfs.ext4 /dev/md0p3
sudo mkfs.ext4 /dev/md0p4
sudo mkfs.ext4 /dev/md0p5
