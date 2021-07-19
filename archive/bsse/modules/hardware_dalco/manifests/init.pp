# WIKI START Recipe Dalco::hardware_dalco
## OS :: Redhat;Ubuntu;Fedora; #Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * Hosts with group hardware-dalco
#
# h3. Services affected
# * *ipmi services running
#
# h3. Files / directories / links affected


# * CREATE : openipmi and ipmitool packages installed 
# * CREATE : On RHEL this is OpenIPMI and ipmitool.
# * ENABLE SERVCE : ipmi
# *  - only starts if it can find the required hardware.
#
# h3. What happens
#
#	* Relation in Centreon set to either Dalco or Dell and appropriate management syste
#         software installed and started.
#
#
###########
# WIKI STOP

class hardware_dalco
{
  case $facts['kernel'] {
    'Linux': {
      case $facts['os']['family'] {
        'Debian': {
           notify { "Dalco hardware with Debian" : }
           package { ['openipmi', 'ipmitool', 'freeipmi', 'libipc-run-perl']:
                   ensure => installed,
                   }
           service { 'openipmi':
                   ensure => 'running',
                   enable => 'true',
                   }
           }
        'RedHat': {
           notify { "Dalco hardware with RedHat" : }
           package { ['OpenIPMI', 'ipmitool']:
           ensure => installed,
           }
           service { 'openipmi':
                   ensure => 'running',
                   enable => 'true',
                   }
          }
        default: {
           notice{"IPMI not supported for this OS" : }
           }
       }
     }
    'SunOS' : {
    }
    default: {
      #
      # warn in the puppet log
      #
      notice("$operatingsystem OS not supported for recipe hw_dalco")
    }
  }
}
