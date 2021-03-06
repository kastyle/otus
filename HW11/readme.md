# **Домашняя работа №11**

## **1. Цель работы**

1. Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен
отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
2. Определить разницу между контейнером и образом. Вывод описать в домашнем задании.
3. Ответить на вопрос: Можно ли в контейнере собрать ядро?
4. Собранный образ необходимо запушить в docker hub и дать ссылку на ваш
репозиторий.

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Github**- система контроля версий;
- **VSCode**- Удобный редактор кода, со множеством полезных функций;
- **Docker** - ПО для автоматизации развёртывания и управления приложениями в средах с поддержкой контейнеризации.
- Все действия выполнялись под **Ubuntu 18.04**

## **2. Docker**

Для начала требуется установить docker. Выполним последовательно команды:
```
sudo apt-get install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
Что бы каждый раз не вводить sudo, добавим пользователя в группу docker:
```
sudo usermod -a -G docker kastyle
```
Проверим, как там дела у докера и если все ок, начнем создавать докерфайл.
![](https://github.com/kastyle/otus/raw/master/HW11/screenshots/s1.png)


Согласно заданию, dockerfile должен содержать следующие инструкции: 
```
FROM - базовый родительский образ;
RUN - используется для выполнения команд и установки пакетов;
COPY - копирует в контейнер файлы и каталоги;
EXPOSE - открывает определенный порт;
CMD - команда, которую нужно выполнить, когда контейнер запустится.
```
Так же, необходимо собрать кастомный nginx. Внесем свои изменения и с помощью COPY отправим нужные нам файлы в контейнер. После всех необходимых действий Dockerfile Будет выглядеть так:

```
FROM alpine:3.11
RUN apk add nginx && apk add apk-tools && apk update && apk upgrade
COPY nginx/index.html /usr/share/nginx/html/index.html
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

Теперь осталось только собрать контейнер и запустить его. Погнали.
Сборка происходит командой:
```
docker build -t CONTAINER_NAME .
```
Теперь можно запускать контейнер.
```
docker run -d -p 8080:8080 CONTAINER_NAME
```
Проверяем, работает ли он. 
![](https://github.com/kastyle/otus/raw/master/HW11/screenshots/s3.png)

Заглянем в браузер:

![](https://github.com/kastyle/otus/raw/master/HW11/screenshots/s5.png)

Да, все в порядке. Пушим образ в docker hub.
```
docker tag 469547603661 kastyle/myhw:release
docker push kastyle/myhw
```
Загрузка прошла успешно.
![](https://github.com/kastyle/otus/raw/master/HW11/screenshots/s4.png)

## **3. Прочее**


**Определить разницу между контейнером и образом** - Докер образ - стек слоев нижнего уровня. Данные слои всегда находятся в read-only режиме и их нельзя изменить. Все изменения происходят в контейнере. Контейнер - завершающий, верхний слой образа. Работает в режиме read-write. 

**Можно ли в контейнере собрать ядро?** - Собрать ядро внутри контейнера представляется возможным, так как это обычный процесс, но загрузиться с него нельзя.

## **4. Для проверки нужно...**

Загрузить репо, выполнить:
```
docker build -t CONTAINER_NAME .
docker run -d -p 8080:8080 CONTAINER_NAME
```
Где, CONTAINER_NAME - имя контейнера, которое можно задать самостоятельно.
Открыть браузер, убедиться, что все работает, контейнер загружен.

http://127.0.0.1:8080/

https://hub.docker.com/r/kastyle/myhw-upd
