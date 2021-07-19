#!/bin/sh
if [ -z $1 ]; then
	USER=bs-admin
else
	USER=$1
fi

echo Binding with user $USER
net ads join createupn="nfs/$HOSTNAME@D.ETHZ.CH" createcomputer=Hosting/BSSE/BSSE-Department/servers/unix -U $USER
