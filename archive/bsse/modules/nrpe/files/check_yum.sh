#!/bin/sh

sudo /usr/lib64/nagios/plugins/check_yum.py
exit $?
