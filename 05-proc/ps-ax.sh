#!/usr/bin/env bash

cols=$(tput cols)

get_tty() {
    hex=$(printf '0x%x\n' $1)
    major=$(($hex >> 8 & 0xFF))
    minor1=$(($hex & 0xF))
    minor2=$(($hex >> 20))
    minor=$((0x$minor2$minor1))
    if [ $major -eq 4 ]; then
	echo tty$minor
    fi

    if [ $major -eq 136 ]; then
	echo pts/$minor
    fi
}

format_seconds() {
    printf '%d:%02d\n' $(($1/60)) $(($1%60))
}

printf "%5s %-8s %-5s %5s %.$((cols-27))s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"
for pid in $(ls /proc | sort -n); do
    [[ ! $pid =~ ([0-9]+) ]] && continue
    TTY=?
    NICE=""
    LOCK=""
    SL=""
    MTHREAD=""
    FG=""
    if [ -f /proc/$pid/stat ]; then
	tty_nr=$(cat /proc/$pid/stat | awk '{print $7}')
	if [ $tty_nr -ne 0 ]; then
	    TTY=$(get_tty $tty_nr)
	fi

	STAT=$(cat /proc/$pid/stat | awk '{print $3}')
	NICE=$(cat /proc/$pid/stat | awk '$19>0 {print "N"};$19<0 {print "<"}')
	VmLck=$(cat /proc/$pid/status | egrep -c "VmLck:.*([1-9])")
	[[ $VmLck -gt 0 ]] && LOCK="L"
	sess_id=$(cat /proc/$pid/stat | awk '{print $6}')
	[[ $sess_id -eq $pid ]] && SL="s"
	MTHREAD=$(cat /proc/$pid/stat | awk '$20>1 {print "l"}')
	FG=$(cat /proc/$pid/stat | awk '$8!=-1 {print "+"}')

	work_ticks=$(cat /proc/$pid/stat | awk '{print $14+$15}')
	work_secs=$(($work_ticks/100))
	TIME=$(format_seconds $work_secs)

	COMMAND=$(sed 's/\x0/ /g' < /proc/$pid/cmdline)
	if [ -z "$COMMAND" ]; then
	    COMMAND="["$(cat /proc/$pid/comm)"]"
	fi
    fi
    printf "%5s %-8s %-5s %5s %.$((cols-27))s\n" $pid $TTY "$STAT$NICE$LOCK$SL$MTHREAD$FG" $TIME "$COMMAND"
done
