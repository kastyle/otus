# **Домашняя работа №10**

## **1. Цель работы**

1. Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:
- Необходимо использовать модуль yum/apt;
- Конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными;
- После установки nginx должен быть в режиме enabled в systemd;
- Должен быть использован notify для старта nginx после установки;
- Cайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible.
* Сделать все это с использованием Ansible роли

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Github**- система контроля версий;
- **VSCode**- Удобный редактор кода, со множеством полезных функций;
- **Ansible** - система управления конфигурациями;
- Все действия выполнялись под **Centos 7 и Ubuntu 18.04**

## **2. Ansible**

На начала подготовим рабочее место: проверим есть ли питон и какая у него версия, установим ansible и создадим нужное окружение.
```
kastyle@admins:~$ python -V
Python 2.7.17

sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible

kastyle@admins:~$ ansible --version
ansible 2.9.7
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/kastyle/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.17 (default, Apr 15 2020, 17:20:14) [GCC 7.5.0]
  ```
  Создаем 2 вагрантфайла, для наших 2-ух серверов. Вагрантфайлы взяты из методички, изменено только имя машин и ip адрес второй машины. Проверяем ssh соединения до каждой машины:
![Проверка](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s2020-04-26%2012-05-35.png)
