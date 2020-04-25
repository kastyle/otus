# **Домашняя работа №9**

## **1. Цель работы**

1. Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников.
2. Дать конкретному пользователю права работать с докером и возможность рестартить докер сервис.

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Github**- система контроля версий;
- **VSCode**- Удобный редактор кода, со множеством полезных функций;
- **Docer** - программное обеспечение для автоматизации развёртывания и управления приложениями в средах с поддержкой контейнеризации.
- Все действия выполнялись под **Centos 7**

## **2. Запрещаем логин пользователям**

Первое, что нам нужно сделать, это добавить пользователей, задать им пароли.
```
[root@centos ~]# useradd admin && useradd vasya-user && useradd liza-user
[root@centos ~]# echo "12345" | passwd --stdin admin && echo "12345" | passwd --stdin vasya-user && echo "12345" | passwd --stdin liza-user 
```
Далее, создаем группы. Для тестирования работы pam будет создано 2 группы: admin и myusers. 
```
[root@centos ~]# groupadd myusers
[root@centos ~]# usermod -a -G myusers vasya-user && usermod -a -G myusers liza-user && usermod -a -G admin admin
```
Чтобы быть уверенными, что на стенде разрешен вход через ssh по паролю, выполним следующую команду:
```
[root@centos ~]# sudo bash -c "sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service"
```
Теперь можно приступать к выполнению. Изночально, задание планировалось сделать через модуль pam_time, что, на первый взгляд, логично и удобно. Но, по тем или иным причинам данный способ оказался не эффективным для групп (для отдельных пользователей все прекрасно работало, но для групп - нет). Так же, данные способ будет не удобен, если администратору приходится часто добавлять или удалять пользователей. Поэтому, задание будет выполнено через модуль **pam_script**, который по итогу оказаля более гибким и удобным решением.

Установим модуль pam_script:
```
[root@centos ~]# yum install pam_script -y
```
Настроим PAM так как по умолчанию данный модуль не подключен:
```
[root@centos ~]# sed -i '2i\ auth  required  pam_script.so'  /etc/pam.d/sshd
```
Проверить успешность добавления команды можно выполнив ```cat /etc/pam.d/sshd```. 

Последнее, что нам нужно сделать, это отредактировать файл /etc/pam_script и дать разрешение на выполнение скрипта.
Напишем простой скрипт, для выполнения данной задачи. Если пользователь состоит в группе admin, разрешаем логиниться сразу. Если пользователя в группе admin нет, проверяем день недели, и если это выходные, то в терминале будет сообщение о запрете доступа.
```
#!/bin/bash

if [[ `grep $PAM_USER /etc/group | grep 'admin'` ]]
then
exit 0
fi
if [[ `date +%u` > 5 ]]
then
exit 1
fi
```
```
[root@centos ~]# chmod +x /etc/pam_script
```
Приступим к проверке.

Данный readme.md пишится в субботу,поэтому, проверять еще удобнее :)

Логинимся под пользоватлем admin:
```
[vagrant@centos ~]$ ssh admin@localhost
The authenticity of host 'localhost (::1)' can't be established.
ECDSA key fingerprint is SHA256:myvRZ5j0dXrNNJtG7Fs8qiKzUFosTUYyVIdUeY+TDfM.
ECDSA key fingerprint is MD5:27:fb:12:91:5b:8c:e8:a1:d4:36:66:23:59:5a:7f:f6.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
admin@localhost's password: 
[admin@centos ~]$
```
Все получилось, пытаемся залогиниться под простым пользоватеем:
```
[vagrant@centos ~]$ ssh liza-user@localhost
liza-user@localhost's password: 
Permission denied, please try again.
liza-user@localhost's password: 
```
Как и следовало ожидать, нас не пускает. Изменим группу пользователя liza-user командой ```usermod -G "" liza-user && usermod -a -G admin liza-user```   и попробуем зайти еще раз:
```
[vagrant@centos ~]$ ssh liza-user@localhost
liza-user@localhost's password: 
Last failed login: Sat Apr 25 07:37:48 UTC 2020 from ::1 on ssh:notty
There were 2 failed login attempts since the last successful login.
[liza-user@centos ~]$ 
```
Получилось!
