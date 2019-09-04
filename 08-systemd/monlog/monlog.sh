#!/usr/bin/env bash

FILE=""
WORD=""

OPTIND=1
while getopts ":f:w:" opt; do
    case ${opt} in
	f)
	    FILE=${OPTARG}
	    ;;
	w)
	    WORD=${OPTARG}
	    ;;
	*)
	    exit 1
	    ;;
    esac
done
shift $((OPTIND-1))

LOG=/vagrant/monlog.log
LINE_FILE=/vagrant/line_last
if [ ! -f $LINE_FILE ]; then
    echo 0 > $LINE_FILE
fi
line_first=$(cat $LINE_FILE)

regex=".*$WORD.*"
line_num=0
while read line; do
    ((line_num++))
    if [[ $line =~ $regex ]]; then
	echo "word \"$WORD\" found in $FILE: $line" >> $LOG
    fi
done < <(tail -n +$(($line_first+1)) $FILE)

echo $(($line_first+$line_num)) > $LINE_FILE
