# **Домашняя работа №7**

## **1. Цель работы**

1. Создать сервис и unit-файлы для этого сервиса:
- сервис: bash, python или другой скрипт, который мониторит log-файл на наличие ключевого слова;
- ключевое слово и путь к log-файлу должны браться из /etc/sysconfig/ (.service);
- сервис должен активироваться раз в 30 секунд (.timer).

2. Дополнить unit-файл сервиса httpd возможностью запустить несколько экземпляров сервиса с разными конфигурационными файлами.

3. Создать unit-файл(ы) для сервиса:
- сервис: Kafka, Jira или любой другой, у которого код успешного завершения не равен 0 (к примеру, приложение Java или скрипт с exit 143);
- ограничить сервис по использованию памяти;
- ограничить сервис ещё по трём ресурсам, которые не были рассмотрены на лекции;
- реализовать один из вариантов restart и объяснить почему выбран именно этот вариант.

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Github**- система контроля версий
- **VSCode**- Удобный редактор кода, со множеством полезных функций;
- Все действия выполнялись под **Ubuntu 18.04.4**

## **2. Создаем сервис и unit-файлы**

Создаем файл с конфигурацией для сервиса. Оттуда он будет брать ключевое слово и знать, где лежит лог

```touch /etc/sysconfig/watchlog
echo 'WORD="failed"
LOG=/var/log/watchlog.log' >> /etc/sysconfig/watchlog
```
Создаем лог, пишем туда любые строки, с содержанием ключевого слова
```
touch /var/log/watchlog.log
echo 'failed
done
done
open
failed' >> /var/log/watchlog.log
```
Создаем скрипт
```
touch /opt/watchlog.sh 
chmod +x /opt/watchlog.sh 
echo '#!/bin/bash
WORD=failed
LOG=/var/log/watchlog.log
DATE=`date`
if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi' >> /opt/watchlog.sh 
```
Создаем юнит для сервиса
```
touch /etc/systemd/system/watchlog.service
echo '[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG' >> /etc/systemd/system/watchlog.service
```
Создаем таймер для сервиса
```
touch /etc/systemd/system/watchlog.timer
echo '
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target' >> /etc/systemd/system/watchlog.timer
```
Запускаем и проверяем результат работы в логе №№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№

## **3. Дополняем unit файл httpd**

Копируем оригинальный сервис и добавляем в конец строки EnvironmentFile -%I
```
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
```
Создаем 2 когфига для httpd
```
touch /etc/sysconfig/httpd-first
echo 'OPTIONS=-f conf/first.conf'
touch /etc/sysconfig/httpd-second
echo 'OPTIONS=-f conf/second.conf'
```
Копируем оригинальные конфиги и правим последний
```
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
```
Проверяем статус сервисов, результат можно посмотреть в логе №№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№№

## **4. Создаем unit файл для jira с ограничениями ресурсов**

Устанавливаем jira
```
yum install wget -y
mkdir /opt/otus ; cd /opt/otus
wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-8.7.1-x64.bin
chmod +x atlassian-jira-software-8.7.1-x64.bin 
./atlassian-jira-software-8.7.1-x64.bin 
chmod 755 /opt/atlassian/jira* 
```
Создаем unit файл, устанавливаем нужные права (согласно документации)

```
touch /lib/systemd/system/jira.service
chmod 664 /lib/systemd/system/jira.service

```
Создаем для юнита ряд ограничений, назначаем авторестарт.
```
MemoryLimit=100M                          #Лимит по памяти
TasksMax=15                               #Лимит по задачам
CPUQuota=30%                              #Лимит использования CPU        
IOWeight=20                               #Лимит использования диска. Уменьшили приоритет
Restart=always                            #Авторестарт при неожиданном завершении процесса
```
Остается только перечитать параметры, добавить сервис в автозагрузку, запустить его и проверить, что все ОК.
```
systemctl daemon-reload
systemctl enable jira.service
systemctl start jira.service
systemctl status jira.service
```






