#!/bin/bash

echo "high and low priority test started at $(date)" > ionicelog.txt

proc1 () {
    ionice -c 1 -n 0 dd if=/dev/urandom of=/tmp/tmp_base.iso bs=30M count=1000 oflag=direct
    echo "high priority test stopped at $(date)" >> ionicelog.txt
}

proc2 () {
    ionice -c 3 dd if=/dev/urandom of=/tmp/tmp_base2.iso bs=30M count=1000 oflag=direct
    echo "low priority test stopped at $(date)" >> ionicelog.txt
}

proc1 &
proc2 &
