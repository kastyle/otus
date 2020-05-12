# **Домашняя работа №13**

## **1. Цель работы**

1. Настроить центральный сервер для сбора логов. В вагранте поднимаем 2 машины web и log. На web поднимаем nginx ,на log настраиваем центральный лог сервер на любой системе на выбор
- journald
- rsyslog
- elk
2. Настраиваем аудит следящий за изменением конфигов нжинкса. Все критичные логи с web должны собираться и локально и удаленно.
Все логи с nginx должны уходить на удаленный сервер (локально только критичные). Логи аудита должны также уходить на удаленную систему.

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Github**- система контроля версий;
- **VSCode**- Удобный редактор кода, со множеством полезных функций;
- Все действия выполнялись под **Centos 7**

## **2. rsyslog**

**Настройка VM log**

Включим брандмауэр и откроем порты для работы rsyslog и audit
```
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --permanent --add-port=514/{tcp,udp}
firewall-cmd --permanent --add-port=60/{tcp,udp}
firewall-cmd --reload
```
Разрешаем соединения по tcp/udp на 514 порту и добавляем шаблон для создания логов. Изменим файл /etc/rsyslog.conf:
```
# Provides UDP syslog reception
$ModLoad imudp
$UDPServerRun 514

# Provides TCP syslog reception
$ModLoad imtcp
$InputTCPServerRun 514

$template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~
```
Перезапускаем сервис:
```
systemctl restart rsyslog.service 
```
Настроим сервер на прием логов на 60 порту. Раскомментируем строчку tcp_listen_port = 60 в файле /etc/audit/auditd.conf перезапустим сервис командой ```service auditd restart```



**Настройка VM web**

Установим nginx и настроим отправку логов. Добавим файл nginx.repo в /etc/yum.repos.d/
```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```
```
yum install nginx
systemctl start nginx
systemctl enable nginx
```
Установим плагин для отправки логов на сервер
```
yum install -y audispd-plugins.x86_64
```
Настраиваем отправку логов на сервер. Создадим файл в /etc/rsyslog.d/ с именем crit.conf

```
*.crit @@192.168.11.101:514
```
Все критические логи будут отправлены по данному ip адресу. После, рестартим rsyslog.

```
Изменим конфиг nginx, что бы он мог отправлять логи на наш сервер:

```
error_log syslog:server=192.168.11.101:514,tag=nginx_error;
error_log  /var/log/nginx/error.log crit;
access_log syslog:server=192.168.11.101:514,facility=local6,tag=nginx_access,severity=info main;
```
Выполним ```nginx -t ``` что бы проверить правильность синтаксиса, и если все ок ```systemctl restart nginx```

```
Включаем отправку логов

```
sed -i 's!active = no!active = yes!' /etc/audisp/plugins.d/au-remote.conf
```
Прописываем адрес отправки логов на сервер
```
sed -i 's!remote_server =!remote_server = 192.168.11.101!' /etc/audisp/audisp-remote.conf
```
Добавим правило для аудита
```
echo '-w /etc/nginx/ -p wa -k nginx_watch' >> /etc/audit/rules.d/audit.rules 
```
Перезапускаем сервис
```
systemctl daemon-reload
service auditd restart
```
Получилось!

***Проверить:
Скопировать все в один каталог и запустить vagrantfile***
