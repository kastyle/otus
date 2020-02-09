# **Домашняя работа №2**

## **1. Цель работы**
Изменить Vagrantfile, создать скрипт для создания рейда, конфиг для автосборки рейда при загрузке. Так же требуется добавить в Vagrantfile дополнительно N кол-во дисков, сломать/починить raid, собрать R0/R5/**R10** на выбор, прописать собранный рейд в конфиг, чтобы рейд собирался при загрузке и создать GPT раздел + 5 партиций.

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Github**- система контроля версий
- **VSCode**- Удобный редактор кода, со множеством полезных функций;
- Все действия выполнялись под **Ubuntu 18.04.3**

## **2. Ход выполнения задания**
Копируем репозиторий тестового стенда на локальную машину;

`git clone git@github.com:erlong15/otus-linux`

Открываем Vagrantfile и добавляем в него диски;

`code Vagrantfile`

```sh
:sata5 => {
        :dfile => './sata5.vdi',
        :size => 250, # Megabytes
        :port => 5
},
:sata6 => {
        :dfile => './sata6.vdi',
        :size => 250, # Megabytes
        :port => 6
},
```
Посмотрим, какие имена присвоены дискам;

`sudo lshw -short | grep disk`

Обнулим суперблоки;

`[vagrant@otuslinux ~]$ sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}`

Создадим RAID10 c 6 дисками и проверим его работоспособность;

```
[vagrant@otuslinux ~]$ sudo  mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}
[vagrant@otuslinux ~]$ sudo cat /proc/mdstat  
Personalities : [raid10]  
md0 : active raid10 sdg[5] sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 512K chunks 2 near-copies [6/6] [UUUUUU]
```
### **Создание mdadm.conf**

Данный конфиг позволяет рейду не сломаться лишний раз при тех или иных условиях. Создадим его.
```
sudo mkdir /etc/mdadm
echo "DEVICE partitions" | sudo tee -a  /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf
```

### **Работа с RAID массивом**

Согласно заданию, требуется имитировать выход из строя диска, и затем, восстановить полную работоспособность массива. Ломать - не строить, дак чего же мы ждем? :))
```
[vagrant@otuslinux ~]$ mdadm /dev/md0 --fail /dev/sdd
[vagrant@otuslinux ~]$ cat /proc/mdstat 
Personalities : [raid10] 
md0 : active raid10 sdg[5] sdf[4] sde[3] sdd[2](F) sdc[1] sdb[0]
      761856 blocks super 1.2 512K chunks 2 near-copies [6/5] [UU_UUU]
```
Теперь восстановим его массив.
```
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --remove /dev/sdd
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --add /dev/sdd
[vagrant@otuslinux ~]$ cat /proc/mdstat 
Personalities : [raid10] 
md0 : active raid10 sdd[6] sdg[5] sdf[4] sde[3] sdc[1] sdb[0]
      761856 blocks super 1.2 512K chunks 2 near-copies [6/6] [UUUUUU]
```
Все получилось.



### **Работа с ФС**
Создадим раздел GPT, партиции и примонтируем их.
```
[vagrant@otuslinux ~]$ sudo  parted -s /dev/md0 mklabel gpt
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
sudo mount /dev/md0p1 /raid/part1/
sudo mount /dev/md0p2 /raid/part2/
sudo mount /dev/md0p3 /raid/part3/
sudo mount /dev/md0p4 /raid/part4/
sudo mount /dev/md0p5 /raid/part5/
```
Вывод команды lsblk

```
[vagrant@otuslinux ~]$ lsblk 
NAME      MAJ:MIN RM   SIZE RO TYPE   MOUNTPOINT
sda         8:0    0    40G  0 disk   
`-sda1      8:1    0    40G  0 part   /
sdb         8:16   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0   150M  0 md     /raid/part3
  |-md0p4 259:3    0 148.5M  0 md     /raid/part4
  `-md0p5 259:4    0   147M  0 md     /raid/part5
sdc         8:32   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0   150M  0 md     /raid/part3
  |-md0p4 259:3    0 148.5M  0 md     /raid/part4
  `-md0p5 259:4    0   147M  0 md     /raid/part5
sdd         8:48   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0   150M  0 md     /raid/part3
  |-md0p4 259:3    0 148.5M  0 md     /raid/part4
  `-md0p5 259:4    0   147M  0 md     /raid/part5
sde         8:64   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0   150M  0 md     /raid/part3
  |-md0p4 259:3    0 148.5M  0 md     /raid/part4
  `-md0p5 259:4    0   147M  0 md     /raid/part5
sdf         8:80   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0   150M  0 md     /raid/part3
  |-md0p4 259:3    0 148.5M  0 md     /raid/part4
  `-md0p5 259:4    0   147M  0 md     /raid/part5
sdg         8:96   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0   150M  0 md     /raid/part3
  |-md0p4 259:3    0 148.5M  0 md     /raid/part4
  `-md0p5 259:4    0   147M  0 md     /raid/part5

```

## **Вывод**
В ходе работы изменили Vagrantfile, создали скрипт для создания рейда, конфиг для автосборки рейда при загрузке. Так же  добавили в Vagrantfile дополнительно 2 диска, сломали и починили raid, собрали **RAID10**, создали GPT раздел и 5 партиций.
