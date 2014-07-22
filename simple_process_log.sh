#!/bin/bash 
# simple script to log time, memory and cpu usage for a specific PID

MY_PID=${1}
# "PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND"
MY_HEADER="PID %CPU %MEM TIME+ COMMAND"
MY_INTERVAL=5
MY_USER="ubuntu"

if [ $# -eq 0 ];then
    echo
    echo "     You have to specify the the process id first (required) and then the log file name (optional)"
    echo
    exit 1;
fi

if [ -n $MY_PID ];then
    echo
    echo "     Process ID is $MY_PID"
    echo
else
    echo
    echo "     You must specify a process id"
    echo
    exit 1
fi

MY_LOG="process_"$MY_PID"_log.txt"

echo "     logging to:"
echo "     $MY_LOG"
echo

ENTRY_COUNTER=0
echo $MY_HEADER > $MY_LOG
while :; do 
    top -n 1 -b -u $MY_USER | grep $MY_PID | awk '{print $1," ",$9," ",$10," ",$11," ",$12}'>> $MY_LOG
    ENTRY_COUNTER=$((ENTRY_COUNTER+1))
    echo "     created log entry ( "$ENTRY_COUNTER" )" 
    sleep $MY_INTERVAL 
done
