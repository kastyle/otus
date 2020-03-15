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
Запускаем, результат работы [можно посмотреть в логе](https://github.com/kastyle/otus/blob/master/HW7/logs/watchlog.log)

## **3. Дополняем unit файл httpd**

Копируем оригинальный сервис и добавляем в конец строки EnvironmentFile -%I
```
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
```
Создаем 2 когфига для httpd
```
touch /etc/sysconfig/httpd-first
echo 'OPTIONS=-f conf/first.conf' >> /etc/sysconfig/httpd-first
touch /etc/sysconfig/httpd-second
echo 'OPTIONS=-f conf/second.conf' >> /etc/sysconfig/httpd-second
```
Копируем оригинальные конфиги и правим последний
```
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
```
Изменяем значения в файле
```
sed -i 's:Listen 80:Listen 8080:' /etc/httpd/conf/second.conf
echo PidFile /var/run/httpd-second.pid >> /etc/httpd/conf/second.conf
```
Проверяем статус сервисов, результат [можно посмотреть в логе](https://github.com/kastyle/otus/blob/master/HW7/logs/httpd.log)

## **4. Создаем unit файл для jira с ограничениями ресурсов**

Устанавливаем jira
```
yum install -y fontconfig java wget
wget с --progress=bar:force https://www.atlassian.com/software/jira/downloads/binary/atlassian-servicedesk-4.7.1.tar.gz
mkdir /opt/atlassian/
tar -xf atlassian-servicedesk-4.7.1.tar.gz
mv atlassian-jira-servicedesk-4.7.1-standalone/ /opt/atlassian/jira/
```
Создаем пользователя, назначаем права на каталоги
```
useradd jira
chown -R jira /opt/atlassian/jira/
chmod -R u=rwx,go-rwx /opt/atlassian/jira/
mkdir /home/jira/jirasoftware-home
chown -R jira /home/jira/jirasoftware-home
chmod -R u=rwx,go-rwx /home/jira/jirasoftware-home
```
Создаем unit файл, устанавливаем нужные права (согласно документации)

```
touch /lib/systemd/system/jira.service
chmod 664 /lib/systemd/system/jira.service

```
Создаем для юнит и ограничения для него, назначаем авторестарт.
```
echo '[Unit] 
Description=Atlassian Jira
After=network.target
[Service] 
Type=forking
User=jira
PIDFile=/opt/atlassian/jira/work/catalina.pid
ExecStart=/opt/atlassian/jira/bin/start-jira.sh
ExecStop=/opt/atlassian/jira/bin/stop-jira.sh
MemoryLimit=100M                                    #Лимит по памяти
TasksMax=15                                         #Лимит по задачам
CPUQuota=30%                                        #Лимит использования CPU
Slice=user-1000.slice                               #Устанаваливаем слайс для юзера
Restart=always                                      #Авторестарт при неожиданном завершении процесса
[Install] 
WantedBy=multi-user.target' >> /lib/systemd/system/jira.service
```
Остается только перечитать параметры, добавить сервис в автозагрузку, запустить его и проверить, что все ОК. [ЛОГ ТУТ](https://github.com/kastyle/otus/blob/master/HW7/logs/jira.log)
```
systemctl daemon-reload
systemctl enable jira.service
systemctl start jira.service
systemctl status jira.service
```
