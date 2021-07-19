#
# Perform a full installation of [KDE](https://wiki.archlinux.org/index.php/KDE)
# via the "kde" package group.
#
class os_linux_arch::kde {
case $operatingsystem {
 /Debian|Ubuntu/ : {
 notify { "Arch kde module is not for Ubuntu!" : }
 }
 /Arch/: {
# For Arch Linux
notify { "This kde module is for Arch only!" : }

  package {['plasma-meta', 'kde-applications-meta']:
    ensure => present,
  }
}
 default: {}
}
  # phonon/vlc audio; we install both backends
#  $phonon_packages = [
#                      'phonon-qt5',
#                      'phonon-qt5-gstreamer',
#                      'phonon-qt5-vlc',
#                      ]
#  package { $phonon_packages:
#    ensure => present,
#  }
}