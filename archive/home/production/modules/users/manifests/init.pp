class users {
# create the root user with the password given
        user {
          'root':
          ensure   => present,
          name     => 'root',
# This was a 2017 BSSE pw!! Forgotten. Escapes were added for some reason.
#         password => '\$1\$.C0wy3vx\$r6Lb1aLMrYCXSQB/caTf/.',
# This is my current root pw with capitals and a .
          password => file('rootpw'),
        }
# Create the user martin if not existing
# password is all lc, is this ...... .
# Also create the home folder if creating the user
# Assign martin to the groups adm, sudo and lpadmin
# Put the public key of martin into the .ssh/authorized_keys file
     if $facts['os']['family'] =~ /Debian/ {
      $usrgroups = ["adm", "sudo", "lpadmin"]
      } else {
      # this is for Arch
      $usrgroups = ["wheel", "sys", "lp"]
      }
        user {
          'martin':
          ensure   => present,
          name     => 'martin',
          password => file('martinpw'),
          managehome => true,
          groups => $usrgroups,
        }
        file {'/home/martin/.ssh':
             ensure => 'directory',
             }
        file { "/home/martin/.ssh/authorized_keys":
                ensure => present,
                path => "/home/martin/.ssh/authorized_keys",
                owner => "martin",
                group => "martin",
                mode => '0640',
                source => "puppet:///modules/users/authorized_keys",
                backup => main,
            }

}
