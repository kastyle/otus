# **Домашняя работа №5**

## **1. Цель работы**

Написать свою реализацию ps ax используя анализ /proc.
Реализовать 2 конкурирующих процесса по IO. пробовать запустить с разными ionice.
Реализовать 2 конкурирующих процесса по CPU. пробовать запустить с разными nice.

**Используемые инструменты:**

- **VirtualBox**- среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant**- ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется VirtualBox;
- **Github**- система контроля версий
- **VSCode**- Удобный редактор кода, со множеством полезных функций;
- Все действия выполнялись под **Ubuntu 18.04.4**

## **2. Для проверки нужно...**

1. Скачать или сделать форк репозитория.
2. Перейти в директорию со криптом и запустить его.
4. Скрипты nice.sh и ionice.sh создают логи своей работы внутри своих каталогов. Скрипт ps.sh выводит результат работы на экран.
