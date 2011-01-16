#!/bin/bash
#
# BASH pizza timer: Starts a countdown for the specified duration and
# displays a status bar along the way. Duration is given similar to
# `sleep' arguments, e.g., 5m 30s.
#
# 20111601 lordi@styleliga.org
#

function extract_as_seconds {
    echo $(echo $1 | grep -oEw '[[:digit:]]+'$2 | awk -F$2 '{print $1*'$3';}')
}

function parse_arguments {
    SECS=$(extract_as_seconds "$*" s 1)
    MINS=$(extract_as_seconds "$*" m 60)
    HOURS=$(extract_as_seconds "$*" h 3600)
    DAYS=$(extract_as_seconds "$*" d 86400)

    DURATION=0
    for second in $DAYS $HOURS $MINS $SECS; do
        DURATION=$(($DURATION+$second))
    done;

    echo $DURATION
}

function print_bar {
    TERMCOLS=$(tput cols)
    BARWIDTH=$(($TERMCOLS - 12))
    BARLEFT=$(($1 * $BARWIDTH / $2))
    BARDONE=$(($BARWIDTH - $BARLEFT))
    BAR=$(printf '#%.0s' `seq 1 $BARLEFT`)$(printf '.%.0s' `seq 1 $BARDONE`})

    printf "%8s [%.${BARWIDTH}s] \r" $1 $BAR
}

function countdown {
    NOW=$(date +%s)
    THEN=$(($NOW + $1))

    echo Due: $(date -d @$THEN)

    while [ $THEN -gt $NOW ]; do 
        print_bar $(($THEN - $NOW)) $1
        sleep 1
        NOW=$(date +%s)
    done;

    print_bar 0 $1
}

DURATION=$(parse_arguments $*)

if [ $DURATION -lt 1 ]; then
    echo "Usage: $0 [duration]"
    echo "Example: $0 5m 30s"
    exit 1
fi;
countdown $DURATION

echo -e '\n\aCountdown finished!'
