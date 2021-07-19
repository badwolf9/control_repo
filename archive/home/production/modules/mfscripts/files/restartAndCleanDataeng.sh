#!/bin/sh -x
service dataeng stop
rmmod ipmi_si
rmmod ipmi_devintf
rmmod ipmi_msghandler
rmmod dell_rbu
service dataeng start
