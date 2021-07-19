class kvmserver
{
   case $kernel {
	"Linux": {
		file {  "/local0/kvm":
			mode => 755,
			ensure => directory,
		}
		file {  "/local0/kvm/bin":
			mode => 755,
			ensure => directory,
		}
		file {  "/local0/kvm/etc":
			mode => 755,
			ensure => directory,
		}
		file {  "/local0/kvm/bin/attach-virtual-disk.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/attach-virtual-disk.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/createNewVM.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/createNewVM.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/detach-virtual-disk.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/detach-virtual-disk.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/dumpconf.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/dumpconf.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/kvm.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/kvm.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/makeKick-el6.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/makeKick-el6.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/makeKick.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/makeKick.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/massiveHostGeneration.sh.example":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/massiveHostGeneration.sh.example"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/registerHost.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/registerHost.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/registerVM.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/registerVM.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/makeKick-iscsi.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/makeKick-iscsi.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/makeKick2-iscsi.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/makeKick2-iscsi.sh"),
			mode => 700,
		}
		file {  "/local0/kvm/bin/makeSnap-via-suspend.sh":
			content => template("$PUPPETFILES/$operatingsystem/local0/kvm/bin/makeSnap-via-suspend.sh"),
			mode => 700,
		}
		if($operatingsystemrelease < 6)
		{
		     package { "kvm":        	ensure => installed;
			  "virt-manager":       ensure => installed;
			  "libvirt.x86_64":  	ensure => installed;
			  "python-virtinst": 	ensure => installed;
			  "kvm-tools":  	ensure => installed;
			  "etherboot-zroms-kvm":ensure => installed;
			  "etherboot-zroms": 	ensure => installed;
			  "macvtap-support":	ensure => installed;
			}
		} else {
			package { "tigervnc":	     ensure => installed;
				  "macvtap-support": ensure => installed;
			}
		}
		service { "libvirtd":
                        ensure => running,
                        enable => true,
                }
		
     	}
	default: {
		#
		# warn in the puppet log
		#
		notice("$kernel OS not supported for recipe kvmserver")
  		}
 	}
}
