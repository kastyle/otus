#!/bin/bash

fnc (){
    for numpid in $(ls /proc/ | grep ^[0-9] | sort -n)
    do
        pid=$(cat /proc/$numpid/stat | awk '{print $1}')

        tty=$(readlink /proc/$numpid/fd/0 | grep -E 'tty|pts' | cut -d "/" -f3)
        [ -z "$tty" ] && tty="?"

        stat=$(cat /proc/$numpid/stat | awk '{print $3}')

        cmd=$(cat /proc/$numpid/cmdline | awk '{print $1}')
        [ -z "$cmd" ] && cmd=$(cat /proc/$numpid/stat | awk '{print $2}')

        hz=$(getconf CLK_TCK)
        utime=$(cat /proc/$numpid/stat | awk '{print $14}')
	    stime=$(cat /proc/$numpid/stat | awk '{print $15}')

	    time=$((($utime+$stime)/$hz))
        
        printf "%s\t%s\t%s\t%s\t%s\n" $pid $tty $stat $time $cmd
        

    done
}
printf "PID\tTTY\tSTAT\tTIME\tCOMMAND\n"
fnc 2>/dev/null
