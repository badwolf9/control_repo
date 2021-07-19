#!/bin/sh

echo "Cleaning and rebuilding RPM DB. Press <return> to continue or <CTRL+C> to stop."
read y
echo Rebuilding, please wait.
rm -f /var/lib/rpm/__db*
rpm --rebuilddb
