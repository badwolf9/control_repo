# WIKI START Recipe group Daemons::nrpe
## OS :: Redhat ; CentOS ; Ubuntu;Fedora; Solaris; #MacOS X
######################################
#
# h3. Centreon dependencies
##EXEC::EXEC_FIND_DEPENDENCIES ###FILEPATH###/###FILENAME###
#
# h3. Services affected
# * *nrpe* enabled and started (defaultnode, without NSCA nodes)
# * *nsca-helper* enabled and started (NSCA nodes only)
#
# h3. Files / directories / links affected
# * DEPLOY : /etc/nagios/nrpe.cfg (Linux)
# * DEPLOY : /usr/nagios/etc/nrpe.cfg (Solaris)
# * DEPLOY : plugin
# ** check_linux_bsse
# ** check_nfs_bsse
#
# h3. What happens
# * Generate a nrpe.cfg in subject to
# ** the number of cores (load threshold)
# * Install all required packages
# * Restart nrpe service (or nsca-help for nsca hosts)
#
# h3. Note
# the parameters {{my_monitor}} and {{my_puppet_server}} come from hieradata
# Postgres monitoring: for database checking ensure user is postgres in command else need to have user nrpe in each database instance
###########
# WIKI STOP
# MJF 2017 08 09
#
define nrpe($allowed_hosts){

   $nrpeservice = 'nrpe'
   $nrpeuser    = 'nrpe'
   $nrpegroup   = 'nrpe'
   $nagiosgroup = 'nagios'
   $myhostname  = $::hostname
   $cltversion  = $::clientversion
   $svrversion  = $::serverversion

   case $::processorcount {
            1: { $load_warn = '5,5,4' $load_crit = '41,41,38' }
            2: { $load_warn = '8,8,6' $load_crit = '10,10,8' }
            3: { $load_warn = '32,32,30' $load_crit = '41,41,38' }
            4: { $load_warn = '32,32,30' $load_crit = '41,41,38' }
            5: { $load_warn = '32,32,30' $load_crit = '41,41,38' }
            6: { $load_warn = '25,25,23' $load_crit = '36,36,38' }
            7: { $load_warn = '28,28,26' $load_crit = '35,35,38' }
            8: { $load_warn = '32,32,30' $load_crit = '41,41,38' }
           16: { $load_warn = '65,65,60' $load_crit = '70,70,68' }
           32: { $load_warn = '65,65,60' $load_crit = '70,70,68' }
           48: { $load_warn = '97,97,95' $load_crit = '110,110,99' }
        default: { $load_warn = '32,32,30' $load_crit = '41,41,38' }
   }
   $my_debugflag = lookup('shallIdebug', Array[String], 'unique')
   case $::kernel {

  'SunOS': {
        $nrpepackage = 'nrpe'
        $pluginsdir = '/usr/nagios/libexec'
        $nrpedir    = '/usr/nagios/etc'

        file { '/usr/nagios/etc': ensure => directory
        }
        file { '/usr/nagios/etc/nrpe.cfg':
          mode       => '0644',
          content    => epp("nrpe/nrpe_solaris.conf.epp", { 
        		    load_warn  => $load_warn,
    			    load_crit  => $load_crit,
		            nrpeuser   => 'nrpe',
		            nrpegroup  => 'nrpe',
    			    monitors    => lookup('my_monitor'),
    			    my_hostname => $myhostname,
    			    puppetsvr   => lookup('my_puppet_server'),
    			    svrver      => $svrversion,
    			    cltver      => $cltversion,
    			    pluginsdir  => '/usr/nagios/libexec'
    			      }),
          require    => [User['nrpe'] ],
          #require   => [User["nrpe"], Package[$nrpepackage,"nagios-plugins"]],
          alias      => nrpeconf
        }
        group { 'nrpe':
          ensure => present,
          gid    => 202,
        }

        user { 'nrpe':
          ensure  => present,
          uid     => 202,
          gid     => 202,
          groups  => 'nrpe',
          shell   => '/bin/false',
          home    => '/usr/nagios',
          require => Group['nrpe'],
        }

        # Additional Plugins
        file { "${pluginsdir}/check_lts.sh":
          mode   => '0755',
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_lts.sh",
          owner  => root,
        }
        file { "${pluginsdir}/check_solaris_swap.pl":
          mode   => '0755',
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_solaris_swap.pl",
          owner  => root,
        }
        file { "${pluginsdir}/check_cpu_usage":
          mode   => '0755',
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_cpu_usage",
          owner  => root,
        }
        file { "${pluginsdir}/checkDirvishnrpe.py":
          mode   => '0755',
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/checkDirvishnrpe.py",
          owner  => root,
        }
        file { "${pluginsdir}/check_nfs_counters.sh":
          mode   => '0755',
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_nfs_counters.sh",
          owner  => root,
        }
        file { "${pluginsdir}/check_python3.sh":
          mode   => '0755',
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_python3.sh",
          owner  => root,
        }
        file { "${pluginsdir}/check_solaris_smf.sh":
          mode   => '0755',
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_solaris_smf.sh",
          owner  => root,
        }
        file { "${pluginsdir}/check_zfs_snapshot":
          mode   => '0755',
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_zfs_snapshot",
          owner  => root,
        }
        file { "${pluginsdir}/check_zpools":
          mode   => '0755',
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_zpools",
          owner  => root,
        }

        file { "${pluginsdir}/check_ram.sh":
          mode    => '0755',
          ensure  => present,
          group   => root,
          source => "puppet:///modules/nrpe/solaris/check_ram.sh",
          owner   => root,
        }

        file { "${pluginsdir}/check_file_age":
          mode    => '0755',
          ensure  => present,
          group   => root,
          source => "puppet:///modules/nrpe/solaris/check_file_age",
          owner   => root,
        }

        file { "${pluginsdir}/check_file_age_ifexists":
          mode    => '0755',
          ensure  => present,
          group   => root,
          source  => "puppet:///modules/nrpe/solaris/check_file_age_ifexists",
          owner   => root,
        }

        file { "${pluginsdir}/check_log-collector":
          mode    => '0755',
          owner   => root,
          group   => root,
          source  => "puppet:///modules/nrpe/check_log-collector",
        }

        file {  '/var/log/nagios-collector.log':
          mode   => '0644',
          ensure => present,
          group  => root,
          owner  => nrpe,
        }


        file {  "${pluginsdir}/check_cpu.sh":
          mode    => '0755',
          ensure  => present,
          group   => root,
          source => "puppet:///modules/nrpe/solaris/check_cpu.sh",
          owner   => root,
        }

        # Install routines
        file { '/lib/svc/method/nrpe':
          ensure => present,
          source => "puppet:///modules/nrpe/solaris/nrpe",
          mode   => '0555',
          owner  => 'root',
          group  => 'bin'
        }

        file { '/var/svc/manifest/network/nrpe.xml':
          ensure => present,
          source => "puppet:///modules/nrpe/solaris/nrpe.xml",
          owner  => 'root',
          group  => 'sys'
        }

#        exec { 'svccfg import /var/svc/manifest/network/nrpe.xml; svcadm enable svc:/network/nrpe':
#        subscribe                                                    => File[ '/lib/svc/method/nrpe', '/var/svc/manifest/network/nrpe.xml']
#        }

        file { "${pluginsdir}/check_postgres.pl":
          mode   => '0755',
          owner  => root,
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_postgres.pl",
        }
        file { "${pluginsdir}/check_database_pgsql":
          mode   => '0755',
          owner  => root,
          ensure => present,
          group  => root,
          source => "puppet:///modules/nrpe/solaris/check_database_pgsql",
        }
        service { 'nrpe':
          ensure    => running,
          enable    => true,
          subscribe => [ File[nrpeconf] ]
        }
  }

  'Linux': {


    $nrpedir = '/etc/nagios'

    case $::operatingsystem {
      /Ubuntu|Debian/:{

            if 'service-nsca' in $my_classes {
              $nrpepackage = 'nsca-client-for-ubuntu-comes-here-see-nrpe-recipe'
            } else {
              $nrpepackage = 'nagios-nrpe-server'
            }
            $pluginsrc = '/usr/lib/nagios/plugins'
            $pluginsdir = "${baseclass::libdir}/nagios/plugins"

            group { 'nrpe':
          ensure => present,
          gid    => 202,
            }
        user { 'nrpe':
          ensure  => present,
          uid     => 202,
          gid     => 202,
          groups  => 'nrpe',
          shell   => '/bin/false',
          home    => '/usr/nagios',
                            require => Group['nrpe'],
                    }
          if $::lsbmajdistrelease =~ /12/ {
              if $my_debugflag == 'yes' {notify { "Ubuntu 12.04 " : }}
              package { $nrpepackage: ensure => installed;
                        'nagios-plugins':       ensure => installed;
                        'nagios-plugins-standard':  ensure => installed;
                        'nagios-plugins-basic':       ensure => installed;
                         }
             }elsif $::lsbmajdistrelease =~ /14/ {
              if $my_debugflag == 'yes' {notify { "Ubuntu 14.04 " : }}
              package { $nrpepackage: ensure => installed;
                        'nagios-plugins':       ensure => installed;
                        'nagios-plugins-standard':  ensure => installed;
                        'nagios-plugins-basic':       ensure => installed;
                        'nagios-plugins-common':       ensure => installed;
                         }
             }else{
             # Since 16.04 packages have changed
              if $my_debugflag == 'yes' {notify { "Ubuntu 16.04++ " : }}
              package { $nrpepackage: ensure => installed;
                        'monitoring-plugins':       ensure => installed;
                        'monitoring-plugins-standard':  ensure => installed;
                        'monitoring-plugins-basic':       ensure => installed;
                        'monitoring-plugins-common':       ensure => installed;
                         }
                  }
          file { "$pluginsdir/check_debian_packages":
              mode => "755",
              owner => root,
              group => root,
              source => "puppet:///modules/nrpe/check_debian_packages",
              ensure => present,
          }
          file { "$pluginsdir/check_apt":
              mode => "755",
              owner => root,
              group => root,
              source => "puppet:///modules/nrpe/check_apt",
              ensure => present,
          }
          file { "$pluginsdir/check_megasasctl":
              mode => "755",
              owner => root,
              group => root,
              source => "puppet:///modules/nrpe/check_megasasctl",
              ensure => present,
          }
#         file { "$pluginsdir/check_users_adv.sh":
#              mode                                                   => "755",
#              owner                                                  => root,
#              group                                                  => root,
#              source                                                 => "puppet:///modules/nrpe/check_users_adv.sh",
#              ensure                                                 => present,
#         }
      }
      default :
      {
          $pluginsrc = '/usr/lib64/nagios/plugins'
          $pluginsdir = "${baseclass::libdir}/nagios/plugins"

          if tagged('service-nsca') {
            $nrpepackage = 'nsca-client'
          } else {
            $nrpepackage = 'nrpe'
          }

          package { $nrpepackage:   ensure => present;
                          'nagios-plugins':   ensure => present;
                          'nagios-plugins-disk':  ensure => installed;
                          'nagios-plugins-users': ensure => present;
                          'nagios-plugins-snmp':  ensure => present;
                          'nagios-plugins-ntp':   ensure => present;
                          'nagios-plugins-file_age': ensure => present;
                          'nagios-plugins-flexlm': ensure => present;
                          'nagios-plugins-load':  ensure => present;
                          'nagios-plugins-log':   ensure => present;
                          'nagios-plugins-mysql': ensure => present;
                          'nagios-plugins-procs': ensure => present;
                          'nagios-plugins-swap':  ensure => present;
                          'perl-Nagios-Plugin':   ensure => present;
                          'perl-version':    ensure => present;
                          'sysstat':    ensure => present;
                          'perl-File-Slurp':  ensure => present;
                          'perl-Sort-Versions':  ensure => present;
                          'perl-DBD-Pg':    ensure => present;
                   }
          if($::operatingsystem !~ /Fedora/){
          if(($::operatingsystem =~ /CentOS/) and ($facts['os']['release']['major'] =~ /6/)){
          package {
            'nagios-addons':  ensure => installed;
          }
          }
          }
	file {	"$pluginsdir/check_yum.py":
	    mode => "755",
	    owner => root,
	    group => root,
	    source => "puppet:///modules/nrpe/check_yum.py",
	    ensure => present,
	}
	file {	"$pluginsdir/check_yum.sh":
	    mode => "755",
	    owner => root,
	    group => root,
	    source => "puppet:///modules/nrpe/check_yum.sh",
	    ensure => present,
	}
          package {
        # FIXME : needs nagios-plugins-pgsql84 if system is not default postgres
                          'nagios-plugins-pgsql': ensure => present;
                          #"nagios-plugins-pgsql84": ensure => present;
        }
      }
      # end of default
    }
    # common stuff
    if($::hostname =~ /bs-svn03|bs-monitor0?|bs-appsvr0?/ ){
      $logcollectormode='666'
    } else {
      $logcollectormode='644'
    }

    file {  "${pluginsdir}/check_log-collector":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_log-collector",

    }

    file {  "${pluginsdir}/check_cpu.sh":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_cpu.sh",

    }

    file {  "${pluginsdir}/check_md_raid.sh":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_md_raid.sh",

    }
    file {  "${pluginsdir}/check_md_raid":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_md_raid",

    }
    file {	"$pluginsdir/check_lts.sh":
	mode => '0755',
	owner => root,
	group => root,
	source => "puppet:///modules/nrpe/check_lts.sh",
	ensure => present,
	}
    file {  "${pluginsdir}/check_dell_bladechassis":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_dell_bladechassis",

    }
    file {  "${pluginsdir}/check_openmanage":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_openmanage",
    }
    file {  '/var/log/nagios-collector.log':
      mode   => $logcollectormode,
      owner  => nrpe,
      group  => root,
      ensure => present,

    }
    file {  "${pluginsdir}/check_updates":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_updates",

    }
    file {  "${pluginsdir}/check_connections":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_connections",

    }
    file {  "${pluginsdir}/check_uptime":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_uptime.sh",

    }

    file {  "${pluginsdir}/check_ram.sh":
      mode   => '0755',
      owner  => root,
      group  => root,
      ensure => present,
      source => "puppet:///modules/nrpe/check_ram.sh",

    }

    file { "${pluginsdir}/check_disk_bsse":
      mode   => '0755',
                  owner  => root,
                   group  => root,
                   ensure => present,
      source => [ "puppet:///modules/nrpe/check_disk_bsse.${::operatingsystem}",
          "puppet:///modules/nrpe/check_disk_bsse.el5" ],

                }
    file { "${pluginsdir}/check_swap_bsse":
      mode   => '0755',
                  owner  => root,
                   group  => root,
                   ensure => present,
      source => [ "puppet:///modules/nrpe/check_swap_bsse.${::operatingsystem}",
          "puppet:///modules/nrpe/check_swap_bsse.el5" ],

                }

    file { "${pluginsdir}/check_linux_bsse":
      ensure => absent,
                }

    file { '/etc/cron.hourly/check_linux_bsse':
      mode    => '0755',
                  owner   => root,
                  group   => root,
                  ensure  => present,
	          content => template("nrpe/check_linux_bsse.erb"),
                }

    file { "${pluginsdir}/check_stat_file.sh":
      mode   => '0755',
                  owner  => root,
                  group  => root,
                  ensure => present,
      source => "puppet:///modules/nrpe/check_stat_file.sh",
                }
    file { "${pluginsdir}/check_nfs_bsse":
      mode   => '0755',
                  owner  => root,
                  group  => root,
                  ensure => present,
      source => "puppet:///modules/nrpe/check_nfs_bsse",
                }
    file { "${pluginsdir}/check_ro_mounts.pl":
      mode    => '0755',
                  owner   => root,
                  group   => root,
      content => template("nrpe/check_ro_mounts.erb"),
      ensure  => present
                }
    file { "${pluginsdir}/check_nfs4.pl":
      mode   => '0755',
                  owner  => root,
                  group  => root,
                  ensure => present,
      source => "puppet:///modules/nrpe/check_nfs4.pl",
                }
    file { "${nrpedir}/nrpe.cfg":
      mode    => '0644',
                  require => Package[$nrpepackage],
                  owner   => $nrpeuser,
                  group   => $nrpegroup,
                  content => template("nrpe/nrpe_linux.conf.erb"),
      alias   => nrpeconf
                }
	file { "$pluginsdir/check_pgactivity":
	    mode => "755",
	    owner => root,
	    group => root,
	    source => "puppet:///modules/nrpe/check_pgactivity",
	    ensure => present,
	}
	file { "$pluginsdir/check_pgsql":
	    mode => "755",
	    owner => root,
	    group => root,
	    source => "puppet:///modules/nrpe/check_pgsql",
	    ensure => present,
	}
	file { "$pluginsdir/check_pgsql_geneious.sh":
	    mode => "755",
	    owner => root,
	    group => root,
	    source => "puppet:///modules/nrpe/check_pgsql_geneious.sh",
	    ensure => present,
	}
#	file {	"$pluginsdir/check_autofs_bsse":
#	    mode => "755",
#	    owner => root,
#	    group => root,
#            content => epp('nrpe/check_autofs_bsse.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], }),
#	    content => template("nrpe/check_autofs_bsse.erb"),
#	    ensure => absent,
#	}
    #
    # Install NRPE package or NSCA stuff + addons
    #
    if !tagged('service-nsca') {
            service { $nrpepackage:
              ensure    => running,
              enable    => true,
        pattern   => 'nrpe',
              subscribe => [ File[nrpeconf], Package[$nrpepackage] ]
            }
    } else {
      notice('Enabling nsca-helper for D-BSSE')

      if( $::fqdn != 'bs-dsvr02.ethz.ch' )
      {
        service { 'nrpe':
                ensure  => stopped,
                enable  => false,
          pattern => 'sbin.nrpe',
              }
      }
      $nscahelper='nsca-helper'
      $nscapackage='nsca'

      package { $nscahelper:     ensure => present;
          $nscapackage:    ensure => present;}

      file { "${nrpedir}/nsca-helper.cfg":
                                mode    => '0600',
                                require => Package[$nscahelper],
                                owner   => $nrpeuser,
                                group   => $nrpegroup,
                                content => template("nrpe/nsca-helper.cfg.erb"),
        alias   => nscaconf,
                        }

      file { "${nrpedir}/send_nsca.cfg":
                                mode    => '0640',
                                require => Package[$nscapackage],
                                owner   => $nrpeuser,
        # Nagios fix for send_nsca / centreon
                                group   => $nagiosgroup,
                                content => template("nrpe/send_nsca.erb"),
                        }

      file { '/etc/logrotate.d/nscahelper':
                                mode    => '0640',
                                content => template("nrpe/nscahelper"),
                        }

            service { $nscahelper:
              ensure    => running,
              enable    => true,
              subscribe => [ File[nrpeconf], File[nscaconf] ]
            }
    }

    if('hw-ibm' in $my_classes){

        file { '/dev/ipmi0':
        mode  => '0660',
        group => $nrpegroup
        }
    }

          if('hw-hp' in $my_classes){

      file { "${pluginsdir}/check_hpasm":
        mode   => '0755',
        owner  => root,
        group  => root,
        ensure => present,
        source => "puppet:///modules/nrpe/check_hpasm",
        }
      file { "${pluginsdir}/check_hplogs.sh":
        mode   => '0755',
        owner  => root,
        group  => root,
        ensure => present,
        source => "puppet:///modules/nrpe/check_hplogs.sh",
        }

    }
  }
   }
}
