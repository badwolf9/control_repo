# == Class: resolv_conf::params
#
# This base class contains default parameters
#
# === Variables
#
# === Inherits
#
class resolv_conf::params {
  $nameservers = lookup('dns_servers')
  #$domainname = lookup('domain')
  $searchpath = lookup('searchpath')
  case $::osfamily {
    'Debian', 'RedHat', 'Suse', 'Linux': {
      $config_file = '/etc/resolv.conf'
    }
    'FreeBSD': {
      $config_file = '/etc/resolv.conf'
    }
    'OpenBSD': {
      $config_file = '/etc/resolv.conf'
    }
    'Archlinux': {
      $config_file = '/etc/resolv.conf'
    }
    'Solaris': {
      # This will only be used on Solaris < 11
      $config_file = '/etc/resolv.conf'
    }
    'AIX': {
      $config_file = '/etc/resolv.conf'
    }
    default: {
      case $::operatingsystem {
        'Gentoo': {
          $config_file = '/etc/resolv.conf'
        }
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }
}
