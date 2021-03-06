# == Class: resolv_conf
#
# This class initializes the resolv_conf class
#
# === Variables
#  [*nameservers*]
#  [*domainname*]
#  [*searchpath*]
#  [*options*]
#
# === Inherits
#  [*resolv_conf::params*]
#
# === Requires
#  [*puppetlabs-stdlib*](https://github.com/puppetlabs/puppetlabs-stdlib)
#
class resolv_conf(
  $nameservers = $resolv_conf::params::nameservers,
  $domainname = undef,
  $searchpath = $resolv_conf::params::searchpath,
  $options = undef,
  $config_file = $resolv_conf::params::config_file,
) inherits resolv_conf::params {
  validate_array( $nameservers )

  if $domainname == undef and $searchpath == [] {
    $domainname_real = $::domain
  } elsif $domainname != undef and $searchpath == [] {
    $domainname_real = $domainname
  } elsif $domainname != undef and $searchpath != [] {
    if $::osfamily != 'Solaris' {
      fail('domainname and searchpath are mutually exclusive parameters')
    }else{
     $domainname_real = $::domain
     }
  }

  if $::osfamily == 'Debian' and $::lsbdistcodename == 'xenial' {
    file { '/run/resolvconf/resolv.conf':
      ensure  => file,
      owner   => 'root',
      group   => 0,
      mode    => '0644',
      content => template('resolv_conf/resolv.conf.erb'),
    }
    file { '/etc/resolv.conf':
      ensure  => link,
      target  => '/run/resolvconf/resolv.conf',
      require => File['/run/resolvconf/resolv.conf'],
    }
  }
  else {
    file { $config_file:
      ensure  => file,
      owner   => 'root',
      group   => 0,
      mode    => '0644',
      content => template('resolv_conf/resolv.conf.erb'),
    }
  }

  if $::osfamily == 'Solaris' and $::operatingsystemmajrelease == '11' {
    exec { 'load resolv.conf in smf':
      command     => '/usr/sbin/nscfg import -f dns/client',
      refreshonly => true,
      subscribe   => File[$resolv_conf::params::config_file],
    }
  }
}
