##

#  Purpose of the file
#
# * Contains some site wide specific settings
# * Generates the my_classes array
# * includes the puppet forge ssh module
# * deploys a spectre-meltdown check script
#
#  See also
#
#
###########
#
# The filebucket option allows for file backups to the server
filebucket { main: server => 'mf-mm02.mjfox.ch' }

# Set global defaults - including backing up all files to the main filebucket and adds a global path
File { backup => main }
Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }

#
#	Global puppet definitions come here
#
###  In puppet 4 the variable must start with a-z or _
$grubpassword="\$1\$6ST3JbqT\$geUL1cEFxfbWXh1ZTEOtm1"

# is this still needed anywhere:
$puppetfileserver="puppet://mf-mm02.mjfox.ch/files"

## default is false!
if $facts['hostname'] =~ /mf-x1c01/ {
#$my_debugflag = 'yes'
$my_debugflag = lookup('shallIdebug')
}else{
$my_debugflag = lookup('shallIdebug')
}
notify { "Debug flag is set to $my_debugflag" : }

# the classes for each node are contained in yaml files under hiera/node directory
# All classes come from Centreon
$my_classes = lookup('my_node_classes', Array[String], 'unique')
if $my_debugflag == 'yes' {
 notify { "My classes are $my_classes " :}
}
# Include all classes from Centreon for the node
include($my_classes)
#include ::ssh

if $facts['fqdn'] == 'mf-mm02.mjfox.ch' {
 class { 'puppetdb': }
 class { 'puppetdb::master::config': 
          puppetdb_server => 'mf-mm02.mjfox.ch',
          }
}


# make sure /root/bin exists
file { "/root/bin":
       mode => '755',
       ensure => directory,
       owner => "root",
       group => "root",
     }


# Make a shell script available for all machines to check vulnerability to spectre or meltdown attacks
  file { "/root/bin/spectre_meltdown.sh":
          owner => "root",
          group => "root",
          mode =>  '0744',
          content => file('os_linux_ubuntu/spectre_meltdown.sh'),
          replace => true,
          }
  notice("spectre-meltdown script file copy done")

$my_kernel = $facts['os']['release']['major']

notice( "OS is $my_kernel")
