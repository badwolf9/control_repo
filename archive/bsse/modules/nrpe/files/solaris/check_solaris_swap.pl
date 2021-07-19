#!/usr/bin/perl -w
#
# Nagios plugin to check free swap space on Solaris.
# Copy to Nagios libexec directory (requires utils.pm from Nagios plugins).
#
# $Id: check_solaris_swap.pl,v 1.2 2008/08/28 14:44:44 kivimaki Exp $
#
# Copyright (C) 2006-2008  Hannu Kivimäki / CSC - Scientific Computing Ltd.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

# ------------------------------ SETTINGS --------------------------------------

use strict;
use Getopt::Long;
use vars qw($opt_h $opt_l $opt_V $opt_w $opt_c);
use lib "/usr/nagios/libexec";
use utils qw(%ERRORS);

my $CMD_SWAP = "/usr/sbin/swap";
if (! -x $CMD_SWAP) {
    print "Error: $CMD_SWAP not found or not executable.\n";
    exit $ERRORS{'UNKNOWN'};
}

# ------------------------------ FUNCTIONS -------------------------------------

sub check_params() {
    GetOptions("h", "l", "V", "w=i", "c=i");

    if ($opt_V) {
        print_info();
        print_version();
        exit $ERRORS{'UNKNOWN'};
    }

    if ($opt_l) {
        print_info();
        print_license();
        exit $ERRORS{'UNKNOWN'};
    }

    if ($opt_h || !$opt_w || !$opt_c || $opt_w < 1 || $opt_w > 100
               || $opt_c < 1 || $opt_c > 100 ) {
        print_info();
        print_help();
        exit $ERRORS{'UNKNOWN'};
    }
}

sub print_info() {
    print "Nagios plugin to check free swap space on Solaris.\n";
    print "Copyright (C) 2006-2008  Hannu Kivimäki / CSC - Scientific Computing Ltd.\n";
}

sub print_help() {
    print "\n";
    print "Usage: check_solaris_swap.pl -h | -w <1-100> -c <1-100>\n";
    print "\n";
    print "   -w  warning threshold percentage (integer)\n";
    print "   -c  critical threshold percentage (integer)\n";
    print "   -h  help (this text)\n";
    print "   -l  license info\n";
    print "   -V  version info\n";
    print "\n";
    print "The critical threshold has always priority, i.e. if\n";
    print "both thresholds are exceeded, a CRITICAL message is returned.\n";
    print "\n";
}

sub print_license() {
    print "\n";
    print "This program is free software; you can redistribute it and/or\n";
    print "modify it under the terms of the GNU General Public License\n";
    print "as published by the Free Software Foundation; either version 2\n";
    print "of the License, or (at your option) any later version.\n";
    print "\n";
    print "This program is distributed in the hope that it will be useful,\n";
    print "but WITHOUT ANY WARRANTY; without even the implied warranty of\n";
    print "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n";
    print "GNU General Public License for more details.\n";
    print "\n";
    print "You should have received a copy of the GNU General Public License\n";
    print "along with this program; if not, write to the Free Software\n";
    print "Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.\n";
    print "\n";
}

sub print_version() {
    my $dollar = "\$";
    print "\n";
    print "\$Id: check_solaris_swap.pl,v 1.2 2008/08/28 14:44:44 kivimaki Exp $dollar\n";
    print "\n";
}

# ----------------------------- MAIN PROGRAM -----------------------------------

check_params();

# Get swap usage status from Solaris:
my @swap_results = split(/ +/, `$CMD_SWAP -s`);
my $swap_used = $swap_results[8];
my $swap_available = $swap_results[10];

# Strip 'k' for kilobytes (tr removes all non numeric characters):
$swap_used =~ tr/[0-9]//cd;
$swap_available =~ tr/[0-9]//cd;

# Calculate swap in megabytes and round to integer:
my $swap_available_m = int ($swap_available / 1024 + 0.5);
my $swap_used_m = int ($swap_used / 1024 + 0.5);
my $swap_total_m = int (($swap_used + $swap_available) / 1024 + 0.5);

# Calculate free swap percentage and round to integer:
my $swap_free_pct = int( ($swap_available / ($swap_used + $swap_available)) * 100 + 0.5);

my $state_text = "- $swap_free_pct% ($swap_available_m of $swap_total_m MB) free";
my $perf_text = "usedSwap=$swap_used_m"."MB freeSwapPercent=$swap_free_pct% swap=$swap_total_m"."MB";

if ($swap_free_pct < $opt_c) {
    print "SWAP CRITICAL $state_text|$perf_text\n";
    exit $ERRORS{'CRITICAL'};
} elsif ($swap_free_pct < $opt_w) {
    print "SWAP WARNING $state_text|$perf_text\n";
    exit $ERRORS{'WARNING'};
}

print "SWAP OK $state_text|$perf_text\n";
exit $ERRORS{'OK'};
