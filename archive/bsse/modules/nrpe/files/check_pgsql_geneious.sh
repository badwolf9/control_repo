#!/bin/sh
#check status of geneious database
/usr/lib64/nagios/plugins/check_pgsql -d geneious -l nrpe
exit $?
