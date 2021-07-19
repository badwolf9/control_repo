## OS :: Redhat;Ubuntu LTS;Solaris;
# WIKI START SSH recipes::scripts_root_bin
######################################
#
# h3. Host / Service groups affected
#
# * *all* for file creation
#
# h3. Services affected
# * *ssh* stuff 
#
# h3. Files / directories / links affected
# * REPLACE :
# * DEPLOY  : some scripts to root/bin folder
#
# h3. What happens
#
#
#
###########
# WIKI STOP

class ssh_itsc::scripts
{
    if $kernel =~ /Linux/
      {
      $roothome = lookup('roothome')
      $rootgroup = lookup('rootgroup')
      file {  "${roothome}/bin/sshCommandWrapper.sh":
        mode    => '0755',
        ensure  => present,
        group   => $rootgroup,
        content => file('ssh_itsc/sshCommandWrapper.sh'),
        owner   => root,
           }
      file {  "${roothome}/bin/dellUpdate.sh":
        mode    => '0755',
        ensure  => present,
        group   => $rootgroup,
        content => file('ssh_itsc/dellUpdate.sh'),
        owner   => root,
           }
      file {  "${roothome}/sshCommandWrapper.sh":
        mode   => '0755',
        ensure => absent,
        group  => $rootgroup,
        owner  => root,
           }
      file {  "${roothome}/bin/addDisk.sh":
        mode   => '0755',
        ensure => present,
        group  => $rootgroup,
        owner  => root,
        content => file('ssh_itsc/addDisk.sh'),
           }
      }

    if 'ou_service_usermanager' in $my_classes {
            file {  "${roothome}/bin/manageGrid.sh":
        mode    => '0755',
        ensure  => present,
        group   => $rootgroup,
        content => file('ssh_itsc/manageGrid.sh'),
        owner   => root,
                 }

        }
}