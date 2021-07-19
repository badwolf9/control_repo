#!/bin/bash

NAGLOG="/var/log/nagios-collector.log"
cat $NAGLOG | perl -e 'while (<stdin>) { ($src,$t,$state,@trash)=split /:/; if($h{$src}{$state}<$t){$h{$src}{$state}=$t; $d{$src}{$state}=$_; }; } foreach $k(keys %h){ foreach(1,2,3) {$l=$d{$k}{$_}; print $l if defined($l); }};' >${NAGLOG}.TMP
mv ${NAGLOG}.TMP $NAGLOG
