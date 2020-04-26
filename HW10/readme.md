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
![ ](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s2020-04-26%2012-05-35.png)

Для подключения к хосту нам необходимо передать множество параметров. Узнать их можно командой vagrant ssh-config:
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s2.png)

Используем эти парметры для создания inventory файла. Файл доступен по ссылке [ТУТ](https://github.com/kastyle/otus/blob/master/HW10/host1/staging/hosts)
Для удобства, создадим еще один файл, ansible.cfg, он облегчит нам жизнь, так как не придется повторно вводить адрес, где лежит инвентори файл. После создания файла удаляем из файла hosts информацию о пользователе, она там больше не нужна. Посмотреть ansible.cfg можно [ЖМЯКНУВ_ТУТ](https://github.com/kastyle/otus/blob/master/HW10/host1/ansible.cfg)
Остается проверить, работает или нет. Выполним команду: 
```
ansible -i staging/hosts all -m ping
```

![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s3.png)

Перейдем к основной части задания.

Научимся пользоваться Ad-Hoc командами, и вополним некоторые из них.
```
ansible -i staging/hosts all -m command -a "uname -r"
```
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s4.png)
```
ansible -i staging/hosts all -m systemd -a name=firewalld
```
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s5.png)
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s6.png)
```
ansible -i staging/hosts all -m yum -a "name=epel-release state=present" -b
```
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s7.png)
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s8.png)

Далее, пишим плейбук для автоматической установки epe-release. Сам плейбук и результат его работы показан на скриншоте.
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s9.png)
Выполним команду, для сравнения выводов между playbook и ad-hoc
```
ansible -i staging/hosts all -m yum -a "name=epel-release state=absent" -b
```
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s10.png)

Создадим файл nginx.yml, допишем его и приведем к следующему виду:
```
---
- name: NGINX | Install and configure NGINX
  hosts: all
  become: true
  
  tasks:
    - name: NGINX | Install EPEL Repo package from standart repo
      yum:
        name: epel-release
        state: present
      tags:
        - epel-package
        - packages

    - name: NGINX | Install NGINX package from EPEL Repo
      yum:
        name: nginx
        state: latest
      tags:
        - nginx-package
        - packages
```
Теперь, так как мы добавили tags мы имеем возможность выводить теги в консоль и выполнять,например, только установку nginx. Выведем теги в консоль и произведем обновление nginx.
```
Теги:
```
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s12.png)
```
Обновление nginx:
```
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s13.png)

ВОУ ВОУ СТОПЭ!!! :) На данном этапе у меня случилось восстание машин. Ни при каком раскладе nginx нехотел обновляться. Но, к счастью я еще не забанен в гугле. Хоть точного ответа на свой вопрос я не получил, но форумы навели на верную мысль,что, дело в epel-release. Не смотря на то, что он установлен, данная ошибка намекает на то, что пкет nginx ansible найти не может. Переустановка epel-release помогла, и теперь мы видим то, что и должны видеть:
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s14.png)

Далее,в данный файл мы добавляем шаблон конфига nginx,а так же модуль, который будет копировать шаблон на наш хост. По заданию, необходимо, что бы nginx слушал на порту 8080, изменяем этот параметр,и добавим handler и notify. Это нужно для перезагрузки сервиса в случае изменения конфига. [ЕСЛИ КЛАЦНУТЬ ТУТ](https://github.com/kastyle/otus/blob/master/HW10/host1/nginx.yml), откроется окончательная версия файла nginx.yml, готовая к выполнению.
Выполнение playbook завершилось успешно.
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s17.png)
Проверяем хост 1:
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s15.png)
Проверяем хост 2:
![](https://github.com/kastyle/otus/raw/master/HW10/screenshots/s16.png)
