# WIKI START Ubuntu config::ufw
## OS :: !Redhat;Ubuntu LTS;!Fedora ; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *Linux Debian type Systems* 
#
# h3. Services affected
# * ufw
#
# h3. Files / directories / links affected
# * 
#
# h3. What happens
#
# * Ensure ufw firewall service is stopped and disabled from running at startup
# *
###########
# WIKI STOP

class os_linux_ubuntu::ufw {
service { 'ufw' :
  ensure => 'stopped',
  enable => 'false',
  }
}