class root_solaris::params {
 	$owner = 'root'
	$group = 'root'
	$mode  = '0755'
 case $::kernel {
   'SunOS': { 
   $root_solaris_source_path = 'puppet:///modules/root_solaris'
	 $root = '/root'
	 $root_bin = '/root/bin'
   }
   default: {
     }
   }
}
