define ssh_itsc::deploy_key (
$ssh_key_type,
$ssh_key,
$ssh_user,
$ssh_name,
$ssh_ensure,
$ssh_options,
) {
  # If there is no record in PuppetDB of the ssh key the function gethost_key will return a NotFound
  # In this case do not try to deploy a key
  if $ssh_key != 'NotFound' {
    ssh_authorized_key { $name:
      ensure => $ssh_ensure,
      user   => $ssh_user,
      name   => $ssh_name,
      type   => $ssh_key_type,
      key    => $ssh_key,
      options => $ssh_options,
      }
   }
}

