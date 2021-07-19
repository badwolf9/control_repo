# WIKI START Recipe Filesystems::autofs
## OS :: Redhat ;Ubuntu LTS;Debian;Fedora; #Solaris; #MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *service-autofs* for file creation
# * *all others* for file deletion
#
# h3. Services affected
# * *autofs* enabled and started in case of service-autofs membership
#
# h3. Files / directories / links affected
# * CREATE : _/net /net4 /net3_
# * CREATE : _/usr/local/<GROUPS>_
# * DEPLOY : _/usr/lib64/nagios/plugins/check_autofs_bsse_
# * CREATE OR DELETE : _/nas-bsse-full-path /nas-bsse_
# * INSTALL perl-ldap, perl-ssl-socket bindings
# * INSTALL : /etc/auto.master
# * INSTALL : /etc/auto.hpcnode
# * INSTALL : /etc/auto.net
# * INSTALL : /etc/auto.net4
# * INSTALL : /etc/auto.direct
# * INSTALL : /etc/openldap/ldap_autofs_query
# * LINK : /etc/auto_home to /etc/openldap/ldap_autofs_query
# * LINK : /etc/auto_nas to /etc/openldap/ldap_autofs_query
# * ADDS LINE TO : /etc/fstab
#
# h3. What happens
#
# * Generate a valid ldap autofs query file in _/etc/openldap/ldap_autofs_query_
# * Generate a valid auto.master and auto.home, auto_home, auto_nas, auto.net4
# * If hosts are part of the nagios group service-autofs :
# ** _/net /net4 /net3_ are generated
# ** NFS3 links _/nas-bsse-full-path /nas-bsse_ are generated
# ** valid software repo NFS4 links in _/usr/local/_ are created
# ** the _/usr/lib64/nagios/plugins/check_autofs_bsse_ test plugin is deployed
# ** service autofs is enabled and started
# * If hosts are not part of the nagios group service-autofs :
# ** _/nas-bsse-full-path /nas-bsse_ are removed
# * /etc/auto.master and related files are installed
# * /etc/openldap/ldap_autofs_query is created for dynamic ldap home folder lookup
# * /etc/auto(_home, _nas) is linked to /etc/openldap/ldap_autofs_query
# * /etc/auto.hpcnode is installed if the host is a hpc node (install-type in /etc/bsse/)
# ** Note that auto.master points the home automount to /etc/auto.hpcnode if host is a hpc node

#
###########
# WIKI STOP

class autofs::config 
{
 if ("service_autofs" in $my_classes) or ("service_autofs_passv" in $my_classes) 
{
  # notify { "Service autofs was triggered...." : }
  #  myclasses    = lookup('my_node_classes'),
  # notify { "We got here and MyClasses are ${myclasses} " : }
  case $::kernel 
  {
   "Linux":
   {
	#
	# For the SC we have a differect link destination (locally)
	#
        package {   "autofs": ensure => installed,
                    alias => autofs_pkg
        }
	file {  "/etc/openldap":
	    mode => '0755',
	    ensure => directory,
	    owner => "root",
	    group => "root",
	}

        if ("service_nfs4client" in $my_classes)
        {
		$nfs4only="yes"
		$ldap_query_version_extension=""
	#	notice("$::hostname will use NFS3 for the home folders!!!")
    } elsif 'service_kerberos' in $my_classes {
        $ldap_query_version_extension=".nfs3"
		$nfs4only="no"
	} else {
		$nfs4only="no"
	}
	if("ou_service_gridnodes_soge" in $my_classes) and  ! ("ou_grid_submit" in $my_classes)
        {
		file { "/etc/auto.direct":
		    owner => "root",
		    group => "root",
		    # mode must be 644 or it don't work - John
		    mode  => '0644',
		    #content  => template("autofs/auto.direct.grid"),
		    content   => epp('autofs/auto.direct.grid.epp' ,  { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'],}), 
		    require => Package[autofs_pkg],
		    replace => true,
		}
	}
	else {
	        file { "/etc/auto.net4":
                    owner => "root",
                    group => "root",
                    mode  => '0755',
                    #content  => template("autofs/auto.net4.erb"),
		    content   => epp('autofs/auto.net4.epp' ,  { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'],}), 
                    require => Package[autofs_pkg],
                    replace => true,
		}
	}
		    
	if ("ou_groups_hierlemann" in $my_classes) or ("service_openbis" in $my_classes) or ("service_kerberos" in $my_classes)
        {
		file { "/etc/auto.misc":
		    owner => "root",
		    group => "root",
		    mode  => '0644',
		    #content  => template("autofs/auto.misc.erb"),
		    content   => epp('autofs/auto.misc.epp' ,  { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'],}), 
		    require => Package[autofs_pkg],
		    replace => true,
		}
	}

    if ("service_kerberos" in $my_classes)
        {
        file { '/etc/fstab':
            ensure => present,
        }->
        file_line { 'Append nas22 to /etc/fstab':
            path => '/etc/fstab',  
            line => 'nas22:/fs2201/bsse_group_itsc_s1 /home nfs vers=4,minorversion=0,sec=krb5 0 0',
        }
    }
	file { "/etc/openldap/ldap_autofs_query":
	    owner => "root",
	    group => "root",
	    mode  => '0711',
	    source  => "puppet:///modules/autofs/ldap_autofs_query$ldap_query_version_extension",
	    require => Package[autofs_pkg],
	    alias => ldapautofsquery,
	    replace => true,
	    backup => main,
	}

#	$automasterpath="autofs/auto.master.erb"

	file { "/etc/auto.master":
	    owner => "root",
	    group => "root",
	    mode  => '0644',
	    replace => true,
	    backup => main,
#	    content => template($automasterpath),
	    content   => epp('autofs/auto.master.epp' ,  { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'my_classes' => $my_classes ,}), 
	    alias => automaster,
	}

    file { "/etc/auto_999home":
        owner => "root",
        group => "root",
        mode  => '0644',
        source  => "puppet:///modules/autofs/auto_999home",
        replace => true,
        backup => main,
    }




	file { "/etc/auto.home":
	    owner => "root",
	    group => "root",
	    mode  => '0644',
	    replace => true,
	    backup => main,
	    content   => epp('autofs/auto.home.epp' ,  { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], }), 
	}
	file { "/etc/auto_nas":
	    ensure => link,
	    target => "/etc/openldap/ldap_autofs_query",
	    require => [ Package[autofs_pkg], File[ldapautofsquery] ],
	    replace => true,
	    backup => main,
	}
	file { "/etc/auto_home":
	    ensure => link,
	    target => "/etc/openldap/ldap_autofs_query",
	    require => [ Package[autofs_pkg], File[ldapautofsquery] ],
	    replace => true,
	    backup => main,
	}

        if ("ou_service_gridnodes" in $my_classes) or ("ou_service_gridnodes_soge" in $my_classes) 
        {
		file { "/etc/auto.hpchome":
		    owner => "root",
		    group => "root",
		    mode  => '0755',
		    #content  => template("autofs/auto.hpchome"),
	            content   => epp('autofs/auto.hpchome.epp' ,  { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'],}), 
		    require => Package[autofs_pkg],
		    replace => true,
		}
	}

   }
   default: {
         notice("$::kernel OS not supported for AUTOFS::config")
   }
  }
 }
}

class autofs::service 
{
 case $::kernel 
 {
  "Linux":
  {
  if ("service_autofs" in $my_classes) or ("service_autofs_passv" in $my_classes)
        {
	case $::operatingsystem
	  {
	   	/Debian|Ubuntu/:{
			$ldapperl="libnet-ldap-perl"
			$socketsslperl="libio-socket-ssl-perl"
		}
	   	default:{
			$ldapperl="perl-LDAP"
			$socketsslperl="perl-IO-Socket-SSL"
		}
	  }

	package { 	$ldapperl: ensure => installed, }
	package {	$socketsslperl: ensure => installed,  }

	if ("ou_groups_cina" in $my_classes) or ("ou_groups_mueller" in $my_classes)
        {
		$do_nas_check=false
	} else {
		$do_nas_check=true
	}

	if ("hw_dell" in $my_classes) or ("hw_ibm" in $my_classes) or ("hw_sw" in $my_classes) or ("hw_hp" in $my_classes)
        {
		$do_bkp_check=false
	} else {
		$do_bkp_check=false
	}


#	notice("check_autofs : NAS tests = $do_nas_check")

 	file { "/net4":
	    owner => "root",
	    group => "root",
	    mode  => '0755',
	    ensure => directory,
	}
	file { "/net3":
	    owner => "root",
	    group => "root",
	    mode  => '0755',
	    ensure => directory,
	}
	file { "$baseclass::libdir/nagios/plugins/check_autofs_bsse":
            owner => "root",
            group => "root",
            mode  => '0755',
	    content  => epp('autofs/check_autofs_bsse.epp' ,  { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'classes' => $my_classes, 'do_bkp_check' => $do_bkp_check,}), 
            require => Package[autofs_pkg],
            replace => true,
        }

	#
	#	The useLocalSoftware links are created by the linkfarm
	#

	file { "/scripts":
		ensure => link,
		target => "/usr/local/itsc/scripts",
		}

	if ("service_nfs4client" in $my_classes)
        {
		file { "/nas-bsse": ensure => absent, }
		file { "/nas-bsse-full-path": ensure => absent, }
	} else {
		file { "/nas-bsse":
			ensure => link,
			target => "/net3/nas-bsse/bsse/fs01/quota",
			}
		file { "/nas-bsse-full-path":
			ensure => link,
			target => "/net3/nas-bsse/root_vdm_3/bsse/fs01/quota",
			}
	}
	service { "autofs":
		ensure => running,
		enable => true,
		hasrestart => false,
		subscribe  => File[automaster],
		pattern => "automount",
		}
    } else {
	file { "/nas-bsse":
		ensure => absent,
	}
	file { "/nas-bsse-full-path":
		ensure => absent,
	}
	file { "/scripts":
		ensure => absent,
	}
	# more quiet
    }
  }
  default: {
	# more quiet
        #notice("$::kernel OS not supported for AUTOFS")
  }
 }
}
