## OS :: Redhat;Ubuntu LTS;Solaris;
# WIKI START SSH recipes::backup
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
# * DEPLOY  : dirvish and other key(s) to selected machines
#
# h3. What happens
#
#
# Get the machines whose keys need to be put on the host and deploy the key
#
###########
# WIKI STOP

class ssh_itsc::backup
{
# 

### new attempt at getting backup array 20180128
## This means that new backup pairs can be added into the common.yaml file of hiera
  if lookup('ssh_itsc::backup')[$hostname] != undef {
    $backup = lookup('ssh_itsc::backup')[$hostname][ssh_backup_host]
    }else{
    $backup = []
    }

# Put the relevant keys in authorized_keys file in ~/.ssh
# The variable $backup contains the name of the hosts whose keys are to be looked up and stored
# Test each block for the existence of the name/machine
# 
  $backup.each |$index, $value| {
  if $my_debugflag == 'yes' {notify { $value: message => " is host $index."    }}
  if $value =~ /^bs-/ {
    # is a machine type
    if $my_debugflag == 'yes' {notify { "$index" : message => "Machine is $value" }}
    ssh_itsc::deploy_key { $value:
      ssh_key_type => 'ssh-rsa',
      ssh_key      => ssh_itsc::gethost_key("${value}"),
      ssh_user     => 'root',
      ssh_name     => "root@$value",
      ssh_ensure   => present,
      ssh_options  => [],
      }
  } else {
    # is a user type
    # test if user ssh key data exists in common.yaml
    if lookup('ssh_itsc::special_keys')[$value] != undef {
    ssh_itsc::deploy_key { $value:
      ssh_key_type => lookup('ssh_itsc::special_keys')[$value][ssh_key_type],
      ssh_key      => lookup('ssh_itsc::special_keys')[$value][ssh_key],
      ssh_user     => lookup('ssh_itsc::special_keys')[$value][ssh_user],
      ssh_name     => $value,
      ssh_ensure   => lookup('ssh_itsc::special_keys')[$value][ssh_ensure],
      ssh_options  => lookup('ssh_itsc::special_keys')[$value][ssh_options],
      }
    }
   }
 }
}