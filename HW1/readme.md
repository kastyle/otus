# **Домашняя работа №1**

## **1. Цель работы**
Познакомиться с такими инструментами как Vagrant и Packer, получить начальные навыки при работе с системой контроля версия github, получить навыки создания кастомных образов виртуальных машин, а так же, по обновлению ядра системы из репозитория.

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Packer**- ПО для создания образов виртуальных машин;
- **Github**- система контроля версий
- Все действия выполнялись под **Ubuntu 18.04.3**

## **2. Ход выполнения задания**

### **Установка ПО**

**VirtualBox**

Переходим по ссылке https://www.virtualbox.org/wiki/Linux_Downloads и скачиваем самую свежую версию под Ubuntu 18.04: virtualbox-6.1_6.1.2

`wget https://download.virtualbox.org/virtualbox/6.1.2/virtualbox-6.1_6.1.2-135662~Ubuntu~bionic_amd64.deb \ && sudo dpkg -i virtualbox-6.1_6.1.2-135662_Ubuntu_bionic_amd64.deb`

**Vagrant**

Переходим по ссылке https://www.vagrantup.com/downloads.html и скачиваем самую свежую версию под Ubuntu 18.04: vagrant_2.2.7

`wget https://releases.hashicorp.com/vagrant/2.2.7/vagrant_2.2.7_x86_64.deb && sudo dpkg -i \ vagrant_2.2.7_x86_64.deb`

**Packer**
 
Переходим по ссылке  https://packer.io/downloads.html и скачиваем самую свежую версию под Ubuntu 18.04:  packer_1.5.1

`wget https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip && sudo unzip -d \ /usr/local/bin/packer packer_1.5.1_linux_amd64.zip  && sudo chmod +x /usr/local/bin/packer`

### **Kernel update**

Далее, необходимо выполнить fork репозитория https://github.com/dmitry-lyutenko/manual_kernel_update

`git clone git@github.com:kastyle/manual_kernel_update.git`

Переходим в репозиторий на локальной машине, запускаем vagrant и логинимся

`vagrant up`

`[vagrant@kernel-update ~]$ uname -r`

`3.10.0-957.12.2.el7.x86_64`

Подключаем репозиторий, откуда потом возьмем необходимую версию ядра.

`sudo yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm`

Ставим ядро

`sudo yum --enablerepo elrepo-kernel install kernel-ml -y`

Обновляем конфиг загрузчика, ставим загрузку нового ядра по умолчанию, ребутаемся, проверяем версию ядра
`sudo grub2-mkconfig -o /boot/grub2/grub.cfg`

`sudo grub2-set-default 0`

`sudo reboot`

`uname -r`

### **Packer**

Создадим образ системы с помощью Packer.  Открыв файл centos.json и поняв, что дефолтные настройки вполне устраивают, выполняем команду:

`packer build centos.json`

В результате работы команды появится файл centos-7.7.1908-kernel-5-x86_64-Minimal.box, он и есть результат ее работы.

`vagrant init`

Тестируем образ.

`vagrant box add --name centos-7-5 centos-7.7.1908-kernel-5-x86_64-Minimal.box`

Копируем vagrantfile и вносим не большие изменения в него в строке :box_name => "centos-7-5"

`vim vagrantfile`

Запускаем виртуальную машину, подключаемся, смотрим версию ядра.

`vagrant up`

`vagrant ssh`  
`vagrant@kernel-update ~]$ uname -r`

`5.5.2-1.el7.elrepo.x86_64`

Еееее:) все круто:)

### **Vagrant cloud**

Теперь, согласно заданию, необходимо опубликовать образ. Логинимся в vagrant cloud и заливаем образ в облако.


`vagrant cloud publish --release kastyle/centos-7-5 1.0 virtualbox centos-7.7.1908-kernel-5-x86_64- \Minimal.box`

## **Вывод**

Получили навыки работы с Vagrant и Packer, получить начальные навыки при работе с системой контроля версия github, получить навыки создания кастомных образов виртуальных машин, а так же, по обновлению ядра системы из репозитория.

Ссылка на Vagrant cloud: https://app.vagrantup.com/kastyle/boxes/centos-7-5
