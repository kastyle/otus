# **Домашняя работа №14**

## **1. Цель работы**

Настраиваем бэкапы с помощью BorgBackup
Настроить стенд Vagrant с двумя виртуальными машинами server и backup.

Настроить политику бэкапа директории /etc с клиента (server) на бекап сервер (backup):
1) Бекап делаем раз в час
2) Политика хранения бекапов: храним все за последние 30 дней, и по одному за предыдущие два месяца.
3) Настроить логирование процесса бекапа в /var/log/ - название файла на ваше усмотрение
4) Восстановить из бекапа директорию /etc с помощью опции Borg mount

Результатом должен быть скрипт резервного копирования (политику хранения можно реализовать в нем же), а так же вывод команд терминала записанный с помощью script (или другой подобной утилиты)

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Github**- система контроля версий;
- **VSCode**- Удобный редактор кода, со множеством полезных функций;
- Все действия выполнялись под **Centos 7**

## **2.   **

**   **
