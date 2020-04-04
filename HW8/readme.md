# **Домашняя работа №8**

## **1. Цель работы**

1. Создать свой RPM пакет (можно взять свое приложение, либо собрать, например,
апач с определенными опциями)
2) Создать свой репозиторий и разместить там ранее собранный RPM

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Github**- система контроля версий
- **VSCode**- Удобный редактор кода, со множеством полезных функций;
- Все действия выполнялись под **Ubuntu 18.04.4**

## **2. Создаем свой RPM**
Дисклеймер: Так как задание выполнялось согласно методичке, второй раз ее переписывать не имеет смысла. Далее будут описаны ключевые этапы выполнения задания.

Согласно методичке, были установлены пакеты redhat-lsb-core,wget,rpmdevtools,rpm-build,createrepo,yum-utils, скачана последняя версия nginx 1.16.1-1 и openssl 1.1.1f и установлены все зависимости для предотвращения ошибок.

Далее, редактируем файл nginx.spec и добавляем паремтр в %build:
```
vim rpmbuild/SPECS/nginx.spec 
--with-openssl=/root/openssl-1.1.1f
```
Командой ```rpmbuild -bb rpmbuild/SPECS/nginx.spec``` собираем RPM пакет.
Устанавливаем созданный пакет, запускаем, добавляем в автозагрузку
```
 yum localinstall -y nginx-1.16.1-1.el7.ngx.x86_64.rpm
 systemctl start nginx
 systemctl enable nginx
 ```
 Создаем каталог в директории nginx который будем использовать в качестве репозитория, копируем собранный пакет, скачиваем в него же percona.
 Инициализируем пакет командой  ```createrepo /usr/share/nginx/html/repo/``` и изменяем конф nginx'a, добавив в location стороку ```autoindex on```.
 Проверяем синтаксис и перезапускаем nginx командами nginx -t и nginx -s reload соответственно.
 
 Проверим доступность репозитория.
 ```
 [root@instance-1centos2 ~]# curl http://35.228.112.147/repo/
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          04-Apr-2020 16:51                   -
<a href="nginx-1.16.1-1.el7.ngx.x86_64.rpm">nginx-1.16.1-1.el7.ngx.x86_64.rpm</a>                  04-Apr-2020 16:44             2170216
<a href="percona-release-1.0-15.noarch.rpm">percona-release-1.0-15.noarch.rpm</a>                  04-Apr-2020 16:50               17424
</pre><hr></body>
</html>
[root@instance-1centos2 ~]# 
```
Добавляем репозиторий в /etc/yum.repos.d:
 ```
 cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://35.228.112.147:8080/repo
gpgcheck=0
enabled=1
EOF

[root@instance-1centos2 ~]# yum repolist enabled | grep otus
otus                      otus-linux                                           2
```
Далее устанавливаем percona.
![install](https://github.com/kastyle/otus/blob/master/HW8/scsh.png)

Репозиторий доступен для проверки по адресу http://35.228.112.147/repo/
