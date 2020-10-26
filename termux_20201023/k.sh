#!/bin/sh
ps -eo pid,args | grep filebrowser | grep -v grep | awk '{print $1}' | xargs -r kill -9
ps -eo pid,args | grep start_termux | grep -v grep | awk '{print $1}' | xargs -r kill -9
ps -eo pid,args | grep sjva.py | grep -v grep | awk '{print $1}' | xargs -r kill -9
ps -eo pid,args | grep ngnix | grep -v grep | awk '{print $1}' | xargs -r kill -9
ps -eo pid,args | grep php-fpm | grep -v grep | awk '{print $1}' | xargs -r kill -9
