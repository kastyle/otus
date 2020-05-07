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

Первое, что сделаем - поправим вермя, дату и часовой пояс на поднятых серверах.
```
yum install chrony
systemctl enable chronyd
systemctl start chronyd
\cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
```

Включим брандмауэр и откроем порты для работы rsyslog
```
systemctl start firewalld.service
systemctl enable firewalld.service
systemctl status firewalld.service
firewall-cmd --permanent --add-port=514/{tcp,udp}
firewall-cmd --reload
```

Так как SElinux работает, требуется настроить и его.

```
yum install policycoreutils-python
semanage port -m -t syslogd_port_t -p tcp 514
semanage port -m -t syslogd_port_t -p udp 514
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

Настройка клиента.

Настраиваем отправку логов на сервер. Созддадим файл в /etc/rsyslog.d/ с именем crit.conf

```
*.crit @@192.168.11.101:514
```
Все критические логи будут отправлены по данному ip адресу. После, рестартим rsyslog.



