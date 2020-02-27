#!/bin/bash

log=/var/log/httpd/access_log
lock=/tmp/lockfile
timefile=/tmp/timefile
oldlog=$(tail -n1 $timefile 2>/dev/null | awk '{print $1,$4}')
newlog=$(tail -n1 $log | awk '{print $1,$4}')

#Проверка существования файла
if [ ! -e $timefile ]
then
   touch $timefile
   echo "Temporary file created"
else
   echo "Temporary file OK"
fi

#Проверка новых записей в файле
if  [ "$newlog" = "$oldlog" ]
   then
   echo "No new requests, exit..."
   exit 1

   else
   echo "Processing requests..."
   (tail -n1 $log) >> $timefile
   
   if ( set -o noclobber; echo "$$" > "$lock") 2> /dev/null;
   then
    trap 'rm -f "$lock"; exit $?' INT TERM EXIT

    log_start=$(head -n1 $log | awk '{print $4,$5}')
    echo "Parsing start: $log_start" >> mail.log
    log_end=$(tail -n1 $log | awk '{print $4,$5}')
    echo "Parsing end: $log_end" >> mail.log

    #Топ 15 IP по колличеству запросов
    echo "Top 15 IP:" >> mail.log
    cat $log | awk '{print $1}' | sort | uniq -dc | sort -nr | head -n15 >> mail.log

    #Топ 15 запрашиваемых адресов
    echo "Top 15 URL:" >>mail.log
    cat $log | awk '{print $7}' | sort | uniq -dc | sort -nr | head -n15 >> mail.log

    #Ошибки
    echo "Errors:" >> mail.log
    cat $log | awk '($9 ~ /[45]../) {print $9}'| sort | uniq -dc | sort -nr | head -n15 >> mail.log

    #Коды возврата 
    echo "Responses:" >> mail.log
    cat $log | awk '{print $9}' | sort | uniq -dc | sort -nr >> mail.log

    rm -f "$lock"
    trap - INT TERM EXIT
    cat mail.log | mail -s "Log statistics" admin@admin.com
    else
    echo "Failed to acquire lockfile: $lock."
    echo "Held by $(cat $lock)"
    
   fi
fi
