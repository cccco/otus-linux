#!/usr/bin/env bash

LOCK_FILE=/home/alan/otus-linux/04-bash/run.lock

if [ -f $LOCK_FILE ]; then
    echo "Working in progress. Please, try again later."
    exit 0
fi

touch $LOCK_FILE

trap 'rm -f ${LOCK_FILE} ; exit 1' 1 2 3 15


LOG_FILE=/home/alan/otus-linux/04-bash/access.log
LINE_FILE=/home/alan/otus-linux/04-bash/line_last

if [ ! -f $LINE_FILE ]; then
    echo 0 > $LINE_FILE
fi

declare -A ips
declare -A urls
declare -A urls_wrong
declare -A http_codes


report_delimiter="----------------------------------------------------------------"
line_first=$(cat $LINE_FILE)
line_last=$(( $RANDOM % 400 + 1000 + $line_first ))

print_sorting_array() {
    local -n arr=$1
    for key in "${!arr[@]}"; do
        printf "%-50s\t%d\n" $key ${arr[$key]}
    done | sort -rn -k2
}

regex="^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) . . \[(.*)\] \".* (\/.*) HTTP.*\" ([0-9]+) .*"

line_num=0
while read line; do
    ((line_num++))
    [ $line_num -lt $line_first ] && continue
    [ $line_num -ge $line_last ] && break

    if [[ $line =~ $regex ]]; then
        [ $(( $line_num - 1 )) -eq $line_first ] && date_begin=${BASH_REMATCH[2]}
	ip=${BASH_REMATCH[1]}
	date_end=${BASH_REMATCH[2]}
	url=${BASH_REMATCH[3]}
	http_code=${BASH_REMATCH[4]}
	((ips["$ip"]++))
	((urls['$url']++))
	((http_codes[$http_code]++))
	if [[ $http_code =~ [4-5]([0-9]{2}) ]]; then
	    ((urls_wrong[$url]++))
	else
	    ((urls[$url]++))
	fi
    fi

done < $LOG_FILE

echo $line_last > $LINE_FILE

report=$(
    echo "analyze date range [ $date_begin - $date_end ]";\

    echo "\ntop 10 ip addresses\n$report_delimiter"; \
    print_sorting_array ips | head -10; \

    echo "\ntop 10 urls\n$report_delimiter"; \
    print_sorting_array urls | head -10; \

    echo "\ntop 10 wrong urls (5**,4**)\n$report_delimiter"; \
    print_sorting_array urls_wrong | head -10; \

    echo "\nstatistics of http codes\n$report_delimiter"; \
    print_sorting_array http_codes
)

echo -e "$report" | mail -s "Report log of [ $date_begin - $date_end ]" alan

rm $LOCK_FILE
