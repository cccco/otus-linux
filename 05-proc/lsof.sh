#!/usr/bin/env bash

if [ $# -lt "1" ]; then
    echo "Usage: $0 <file or directory>"
    exit 1;
fi

seacrh=$1

format="%-9s %5s %10s %4s %6s %6s %8s %6s %-30s\n"

device_to_dec() {
    hex=0x$1
    major=$(($hex >> 8 & 0xFF))
    minor=$(($hex & 0xFF))
    echo "$major,$minor"
}

parse_pid() {
    pid=$1
    COMMAND=$(cat /proc/$pid/stat | awk '{print $2}' | sed -E 's/\(|\)//g')
#/'
    USER=$(stat -c "%U" /proc/$pid)
    echo "${COMMAND:0:9} $pid $USER"
}

parse_lk() {
    lk=$1
    stat_array=( $(stat -c "%D %s %i" $lk) )
    DEVICE=${stat_array[0]}
    echo "$(device_to_dec $DEVICE) ${stat_array[1]} ${stat_array[2]} $lk"
}

printf "$format" "COMMAND" "PID" "USER" "FD" "TYPE" "DEVICE" "SIZE/OFF" "NODE" "NAME"

for pid in $(ls /proc/ | grep -v '^[a-zA-Z]' | sort -n); do
    lk=$(readlink /proc/$pid/cwd)
    if [ "$lk" == "$seacrh" ]; then
	FD="cwd"
	TYPE="DIR"
	printf "$format" $(parse_pid $pid) $FD $TYPE $(parse_lk $lk)
    fi

    lk=$(readlink /proc/$pid/root)
    if [ "$lk" == "$seacrh" ]; then
	FD="rtd"
	TYPE="DIR"
	printf "$format" $(parse_pid $pid) $FD $TYPE $(parse_lk $lk)
    fi

    for fd in $(ls /proc/$pid/fd/ 2>/dev/null); do
	lk=$(readlink /proc/$pid/fd/$fd)
	if [ "$lk" == "$seacrh" ]; then
	    access=$(stat -c "%a" /proc/$pid/fd/$fd)
	    [ $access -ge 200 ] && FD=$fd"w"
	    [ $access -ge 400 ] && FD=$fd"r"
	    [ $access -ge 600 ] && FD=$fd"u"
	    TYPE="REG"
	    printf "$format" $(parse_pid $pid) $FD $TYPE $(parse_lk $lk)
	fi
    done


    for lk in $(readlink /proc/$pid/map_files/*); do
	if [ "$lk" == "$seacrh" ]; then
	    FD="mem"
	    TYPE="REG"
	    printf "$format" $(parse_pid $pid) $FD $TYPE $(parse_lk $lk)
	fi
    done

done
