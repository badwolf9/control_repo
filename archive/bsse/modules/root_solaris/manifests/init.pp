##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Systemconfig::root_solaris
## OS :: !RedHat;!Ubuntu ;!Fedora ; Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *os-sun-solaris11* 
#
# h3. Services affected
# * *none* 
#
# h3. Files / directories / links affected
# * DEPLOY : /root/.profile
# * DEPLOY : /root/bin/*
#
# h3. What happens
#
# * Deploy /root.profile
# * Deploy scripts 
#
###########
# WIKI STOP
class root_solaris (
    $root_solaris_source_path  = $root_solaris::params::root_solaris_source_path,
    $root                      = $root_solaris::params::root,
    $root_bin                  = $root_solaris::params::root_bin,
) inherits root_solaris::params {

  case $facts['kernel'] {
 'SunOS': {
                #
                #       Base directories
                #
        file {  "/${root_bin}":                  ensure => directory;
                "/${root_bin}/pythonModules":    ensure => directory;
                "/${root_bin}/storageReports":   ensure => directory;
                "/${root_bin}/snapshotManager":  ensure => directory;
	}
  file { "${root}/.profile":
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content =>  file("root_solaris/${root}/.profile"),
        }
	file { "/root/.screenrc":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content =>  file("root_solaris/${root}/.screenrc"),
	}
  file { "${root_bin}/cleanUpSnapshots.sh":
    mode   => $mode,
    owner  => $owner,
    group  => $group,
    content => file("root_solaris/${root_bin}/cleanUpSnapshots.sh"),
    ensure =>  present
  }

  file { "${root_bin}/minimizeZfsSnapshots.sh":
    mode   => $mode,
    owner  => $owner,
    group  => $group,
    content => file("root_solaris/${root_bin}/minimizeZfsSnapshots.sh"),
    ensure =>  present
  }

  file { "${root_bin}/snapshotZfs.sh":
    mode   => $mode,
    owner  => $owner,
    group  => $group,
    content => file("root_solaris/${root_bin}/snapshotZfs.sh"),
    ensure =>  present
  }
	file { "${root_bin}/joinAD.sh":
    owner => $owner,
    group => $group,
    mode  => '0750',
    content => file("root_solaris/${root_bin}/joinAD.sh"),
  }
	file { "${root_bin}/groupmap.sh":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/groupmap.sh"),
	}
	file { "${root_bin}/backuprpool.sh":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/backuprpool.sh"),
	}
	file { "${root_bin}/enableOpenLDAP_SUN.sh":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/enableOpenLDAP_SUN.sh"),
	}
	file { "${root_bin}/sshCommandWrapper.sh":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/sshCommandWrapper.sh"),
	}
	file { "${root_bin}/netSpeed.sh":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/netSpeed.sh"),
	}
	file { "${root_bin}/compressNagiosCollectorLog.sh":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/compressNagiosCollectorLog.sh"),
	}
	file { "${root_bin}/pythonModules/dbconnect.py":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/pythonModules/dbconnect.py"),
	}
	file { "${root_bin}/pythonModules/logCollector.py":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/pythonModules/logCollector.py"),
	}
	file { "${root_bin}/snapshotManager/manage.py":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/snapshotManager/manage.py"),
	}
	file { "${root_bin}/storageReports/dbUpdateDir.py":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/storageReports/dbUpdateDir.py"),
	}
	file { "${root_bin}/storageReports/dbUpdateZfs.py":
    owner => $owner,
    group => $group,
    mode  => $mode,
    content => file("root_solaris/${root_bin}/storageReports/dbUpdateZfs.py"),
	}
  }
  default: {
	notice("$operatingsystem not supported for root_solaris")
  }
}
}
