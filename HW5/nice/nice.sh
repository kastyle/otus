#!/bin/bash

echo "high and low priority test started at $(date)" > log.txt

proc1 () {
    nice -n 19 dd if=/dev/urandom of=/dev/null bs=128M count=2000
    echo "low priority test stopped at $(date)" >> log.txt
}

proc2 () {
    nice -n -20 dd if=/dev/urandom of=/dev/null bs=128M count=2000
    echo "high priority test stopped at $(date)" >> log.txt
}

proc1 &
proc2 &
