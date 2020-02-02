#!/bin/bash

(echo > "/dev/tcp/127.0.0.1/53") >/dev/null 2>&1
if [ "$?" -gt 0 ]; then
    exit 2
fi

if [ $(dig +short otuslab.ru @127.0.0.1) != "192.168.11.147" ]; then
    exit 1
fi
