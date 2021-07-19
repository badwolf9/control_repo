# WIKI START Recipe Systemconfig::LinkFarm
## OS :: Redhat ;Ubuntu;Fedora; Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *Unix*
#
# h3. Services affected
#
# * *none*
#
# h3. Files / directories / links affected
#
# * CREATE : /links
# * CREATE : /links/*
#
# h3. What happens
#
# * Create a link farm and keep it updated
#
###########
# WIKI STOP

class linkfarm {

  case $::kernel
  {
	/Linux|SunOS/: {
		#
		#	Host declarations
		#
        if 'ou_service_gridnodes_soge' in $my_classes {
           if $my_debugflag == 'yes' { notify{"Reading SOGE OKAY " : }}
            $link_swsvr 	= "bs-gridsw"
                } else {
            $link_swsvr 	= "bs-sw"
		 }
        $link_homesvr           = "bs-home"
		$link_gridhomesvr       = "bs-gridhome"
		$link_gridfilesvr       = "bs-gridfs"
		$link_gridswsvr         = "bs-gridsw"
		$link_grpsvr1           = "bs-filesvr01"
		$link_appsvr1           = "bs-filesvr01"
		$link_grpsvr2           = "bs-filesvr02"
		$link_grpsvr5           = "bs-filesvr05"
		$link_lightsheetsvr	= "bs-filesvr06"
		$link_dsu_dsssvr        = "bs-dsvr44"
		$link_dsu_dssarchivesvr	= "bs-ssvr02"
		$link_dsu_backupsvr     = "bs-ssvr06"
		$link_dsu_backupsvr2    = "bs-backupsvr01"
		$link_homebackupsrv     = "bs-backupsvr01"
		$link_groupbackupsrv    = "bs-backupsvr01"
		$link_groupbackupsrv2   = "bs-backupsvr02"
		$link_nas_bsse          = "nas-bsse"
		$link_sonas_bsse        = "nas22"
		$link_lts_bsse          = "lts11"
		$link_lts_repl_bsse     = "lts21"
    		$link_appsvr2           = "bs-sw"

		#
		#	Link declarations
		#
        $link_swbaseusrlocal	= "/net/$link_swsvr/sw-repo"
		$link_net3swbase        = "/net3/$link_swsvr/sw-repo"
	 	$link_swbase            = "/net/$link_swsvr/sw-repo"
		$link_gridbase          = "/net/$link_gridswsvr/sw-repo"
        $link_gridfsbase        = "/net/$link_gridfilesvr/gridexport"
		$link_nfssharedbase     = "/net/$link_grpsvr1/export/shared"
		$link_app1base          = "/net/$link_appsvr1/export/application"
		$link_app2base          = "/net/$link_appsvr2/sw-repo"
		$link_dsu               = "/net/$link_dsu_dsssvr/export/dsu"
		$link_dsu_dssarchive    = "/net/$link_dsu_dssarchivesvr/export/dsu"
		$link_dsu_backup        = "/net/$link_dsu_backupsvr/array0/snapshots/dsu"
		$link_dsu_backup2       = "/net/$link_dsu_backupsvr2/array0/snapshots/dsu"
		$link_grpbase1          = "/net/$link_grpsvr1/export/group"
		$link_grpbase2          = "/net/$link_grpsvr2/export/group"
		$link_grpbase5          = "/net/$link_grpsvr5/export/group"
		$link_lightsheetbase	= "/net/$link_lightsheetsvr/export/lightsheet"
		$link_homebackup        = "/net/$link_homebackupsrv/array0/snapshots/home"
		$link_gridhomebackup    = "/net/$link_homebackupsrv/array0/snapshots/gridhome"
		$link_groupbackup       = "/net/$link_groupbackupsrv/array0/snapshots/group"
		$link_groupbackup2       = "/net/$link_groupbackupsrv2/array0/snapshots/group"
		$link_homebase          = "/net/$link_homesvr/export/home"
		$link_gridhomebase      = "/net/$link_gridhomesvr/export/gridhome"
		$link_nas_base          = "/net3/$link_nas_bsse/bsse/fs01/quota"
		$link_sonas_base        = "/net3/$link_sonas_bsse/nas/fs2201"
		$link_lts_base          = "/lts/$link_lts_bsse/shares/bsse_lts_nfs"
		$link_lts_repl_base     = "/lts/$link_lts_repl_bsse/shares/bsse_lts_nfs_repl"
	
		#
		#	Base directories
		#
		file { 	"/links": 	 	ensure => directory;
			"/links/backups":  	ensure => directory;
			"/links/backups/groups":ensure => directory;
			"/links/backups/dsu":	ensure => directory;
			"/links/homes":  	ensure => directory;
			"/usr/local":  		ensure => directory;
			"/links/groups": 	ensure => directory;
			"/links/shared": 	ensure => directory;
			"/links/application": 	ensure => directory;
			"/links/grid":		ensure => directory;
			"/links/nas":		ensure => directory;
			"/links/sonas":		ensure => directory;
			"/links/lts":		ensure => directory;
			"/links/lightsheet":	ensure => directory;
		#
		#	Home links
		#
		 	"/links/homes/home": 	target => "$link_homebase",
					     	ensure => link,
		   			     	replace => true;
			"/links/homes/gridhome":target => "$link_gridhomebase",
					     	ensure => link,
		   			     	replace => true;
			"/links/homes/sc_home":
					     	ensure => absent;
		#
		#	NAS (Zurich) links
		#
		 	"/links/nas/archive": 	target => "$link_nas_base/archive",
					     	ensure => absent;
		 	"/links/sonas/cisd":   	ensure => absent;
		 	"/links/sonas/itsc": 	target => "$link_sonas_base/bsse_group_itsc_s1",
					     	ensure => link,
		   			     	replace => true;
		 	"/links/lts/qgf": 	target => "$link_lts_base/qgf",
					     	ensure => link,
		   			     	replace => true;
		 	"/links/lts/qgf_ro": 	target => "$link_lts_repl_base/qgf",
					     	ensure => link,
		   			     	replace => true;
		 	"/links/lts/hierlemann": 	target => "$link_lts_base/hierlemann",
					     		ensure => link,
		   			     		replace => true;
		#
		#	Group directories
		#
		#
			"/links/groups/bewi":		target => "$link_grpbase5/beerenwinkel",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/beerenwinkel":	target => "$link_grpbase5/beerenwinkel",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/benenson":	target => "$link_grpbase1/benenson",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/borgwardt":	target => "$link_grpbase1/borgwardt",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/cina":		target => "$link_grpbase1/cina",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/sis":		target => "$link_grpbase1/sis",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/cisd":		target => "$link_grpbase1/sis",
					     		ensure => absent;
			"/links/groups/dittrich":	target => "$link_grpbase1/dittrich",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/fussenegger":	target => "$link_grpbase1/fussenegger",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/hima":		target => "$link_grpbase1/hierlemann",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/hierlemann":	target => "$link_grpbase1/hierlemann",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/iber":		target => "$link_grpbase5/iber",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/itsc":		target => "$link_grpbase1/itsc",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/khammash":	target => "$link_grpbase1/khammash",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/mueller":	target => "$link_grpbase1/mueller",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/panke":		target => "$link_grpbase1/panke",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/pantazis":	target => "$link_grpbase1/pantazis",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/paro":		target => "$link_grpbase1/paro",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/reddy":		target => "$link_grpbase1/reddy",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/scu":		target => "$link_grpbase1/scu",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/schroeder":	target => "$link_grpbase5/schroeder",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/stadler":	target => "$link_grpbase1/stadler",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/stel":		target => "$link_grpbase1/stelling",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/stelling":	target => "$link_grpbase1/stelling",
					     		ensure => link,
		   			     		replace => true;
			"/links/groups/tay":   		ensure => absent;

		#
		#	Shared directories
		#
			"/links/shared/software":		target => "$link_nfssharedbase/software",
					     			ensure => link,
		   			     			replace => true;
			"/links/shared/temp":			target => "$link_nfssharedbase/temp",
					     			ensure => link,
		   			     			replace => true;
			"/links/shared/deepseq-analysis-data":	target => "$link_nfssharedbase/deepseq-analysis-data",
					     			ensure => link,
		   			     			replace => true;
			"/links/shared/trxG_project":		target => "$link_nfssharedbase/trxG_project",
					     			ensure => link,
		   			     			replace => true;
			"/links/shared/studentdata":		target => "$link_nfssharedbase/studentdata",
					     			ensure => link,
		   			     			replace => true;
			"/links/shared/dsu":			target => "$link_dsu",
					     			ensure => link,
		   			     			replace => true;
			"/links/shared/dsu-dssarchive":		target => "$link_dsu_dssarchive/dss_archive",
					     			ensure => link,
		   			     			replace => true;
			"/links/lightsheet/hierlemann":		target => "$link_lightsheetbase/hierlemann",
						     		ensure => link,
		   				     		replace => true;
			"/links/lightsheet/iber":		target => "$link_lightsheetbase/iber",
						     		ensure => link,
		   				     		replace => true;
			"/links/lightsheet/pantazis":		target => "$link_lightsheetbase/pantazis",
						     		ensure => link,
		   				     		replace => true;
			"/links/lightsheet/paro":		target => "$link_lightsheetbase/paro",
						     		ensure => link,
		   				     		replace => true;
		#
		#	Grid shares
		#
			"/links/grid/scratch":		target => "$link_gridfsbase/scratch",
					     		ensure => link,
		   			     		replace => true;
			"/links/grid/shared":		target => "$link_gridfsbase/shared",
                                ensure => link,
		   			     		replace => true;
			"/links/grid/gridhomes":	target => "$link_gridhomebase",
                                ensure => link,
		   			     		replace => true;
			"/links/grid/software":		target => "$link_gridbase",
					     		ensure => link,
		   			     		replace => true;
		#
		#	Applications
		#
			"/links/application/dsu":		target => "$link_app2base/dsu",
					   			ensure => link,
                                replace => true;
			"/links/application/cifex":
					   			ensure => absent;
		#
		#	Backup directories
		#
			"/links/backups/dsu/bsse":		target => "$link_dsu_backup/bsse/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/dsu/deepseq":		target => "$link_dsu_backup/deepseq/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/dsu/dss":		target => "$link_dsu_backup/dss/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/dsu/runs":		target => "$link_dsu_backup2/runs/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/dsu/runs.old":
					     			ensure => absent;
			"/links/backups/groups/benenson":	target => "$link_groupbackup/benenson/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
#   Temporarily disabled. See OTRS#1074762 
			"/links/backups/groups/borgwardt":
					     			ensure => absent;
			"/links/backups/groups/beerenwinkel":	target => "$link_groupbackup2/beerenwinkel/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/cina":		target => "$link_groupbackup/cina/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/cisd":
					     			ensure => absent;
			"/links/backups/groups/sis":		target => "$link_groupbackup/sis/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/dittrich":	target => "$link_groupbackup/dittrich/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/fussenegger":	target => "$link_groupbackup/fussenegger/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/hierlemann":	target => "$link_groupbackup/hierlemann/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/hima":		target => "$link_groupbackup/hierlemann/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/iber":		target => "$link_groupbackup2/iber/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/itsc":		target => "$link_groupbackup/itsc/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/khammash":	target => "$link_groupbackup/khammash/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/mueller":	target => "$link_groupbackup/mueller/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/panke":		target => "$link_groupbackup/panke/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/pantazis":	target => "$link_groupbackup/pantazis/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/paro":		target => "$link_groupbackup/paro/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/reddy":		target => "$link_groupbackup/reddy/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/scu":		target => "$link_groupbackup/scu/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/schroeder":	target => "$link_groupbackup2/schroeder/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/stadler":	target => "$link_groupbackup/stadler/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/stelling":	target => "$link_groupbackup/stelling/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/stel":		target => "$link_groupbackup/stelling/.zfs/snapshot",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/groups/tay":
					     			ensure => absent;
			"/links/backups/home":			target => "$link_homebackup",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/gridhome":		target => "$link_gridhomebackup",
					     			ensure => link,
		   			     			replace => true;
			"/links/backups/$hostname": 		target => "/net/bs-dirvish/export/dirvishBank/$hostname",
								ensure => link,
                                                                replace => true;

		#
		#	Software repo
		#
			"/usr/local/dsu":  target => "$link_swbaseusrlocal/dsu",
					     ensure => link,
					     replace => true;
			"/usr/local/scu":  target => "$link_swbaseusrlocal/scu",
					     ensure => link,
					     replace => true;
			"/usr/local/bsse": target => "$link_swbaseusrlocal/bsse",
					     ensure => link,
					     replace => true;
			"/usr/local/itsc": target => "$link_swbaseusrlocal/itsc",
					     ensure => link,
		   			     replace => true;
			"/usr/local/bewi": target => "$link_swbaseusrlocal/beerenwinkel",
					     ensure => link,
					     replace => true;
			"/usr/local/beerenwinkel": target => "$link_swbaseusrlocal/beerenwinkel",
					     ensure => link,
					     replace => true;
			"/usr/local/borgwardt": target => "$link_swbaseusrlocal/borgwardt",
					     ensure => link,
					     replace => true;
			"/usr/local/cina": target => "$link_swbaseusrlocal/cina",
					     ensure => link,
					     replace => true;
			"/usr/local/iber": target => "$link_swbaseusrlocal/iber",
					     ensure => link,
					     replace => true;
			"/usr/local/cisd": target => "$link_swbaseusrlocal/cisd",
					     ensure => link,
					     replace => true;
			"/usr/local/grid": target => "$link_gridbase/grid",
					     ensure => link,
					     alias => gridswlink,
					     replace => true;
			"/usr/local/hierlemann":   target => "$link_swbaseusrlocal/hierlemann",
					     force => true,
					     ensure => link,
					     replace => true;
			"/usr/local/hima":   target => "$link_swbaseusrlocal/hierlemann",
					     force => true,
					     ensure => link,
					     replace => true;
			"/usr/local/hpc":  target => "/usr/local/grid",
					     ensure => link,
					     replace => true;
			"/usr/local/khammash": target => "$link_swbaseusrlocal/khammash",
					     ensure => link,
					     replace => true;
			"/usr/local/panke":target => "$link_swbaseusrlocal/panke",
					     ensure => link,
					     replace => true;
			"/usr/local/paro": target => "$link_swbaseusrlocal/paro",
					     ensure => link,
					     replace => true;
			"/usr/local/reddy": target => "$link_swbaseusrlocal/reddy",
					     ensure => link,
					     replace => true;
			"/usr/local/stadler": target => "$link_swbaseusrlocal/stadler",
					     ensure => link,
					     replace => true;
			"/usr/local/stel": target => "$link_swbaseusrlocal/stelling",
					     ensure => link,
					     replace => true;
			"/usr/local/stelling": target => "$link_swbaseusrlocal/stelling",
					     ensure => link,
					     replace => true;
		#
		#	Other	(some links still come from recipe autofs)
		#
		#	"/scripts": 	     target => "/usr/local/itsc/scripts",
		#			     ensure => link,
		#			     replace => true;
		}
		if 'ou_groups_hierlemann' in $my_classes {
			file { 	"/usr/pack": target => "/usr/local/hierlemann/pack",
						ensure => link,
						replace => true;
				"/usr/sepp": target => "/usr/local/hierlemann/sepp",
						ensure => link,
						replace => true;
				"/links/bs-hierlemann01": target => "/nfs4/bs-hierlemann01",
							ensure => link,
							replace => true;
				"/links/bs-hierlemann02": target => "/nfs4/bs-hierlemann02",
							ensure => link,
							replace => true;
				"/links/bs-dsvr14": target => "/nfs4/bs-dsvr14",
							ensure => link,
							replace => true;
			}
		}
		if 'ou_groups_cina' in $my_classes  {

		  file { 	"/links/cina-qnap01":  	ensure => directory;
                                "/links/cina-qnap01/cina_k2": target => "/net3/cina-qnap01/cina_k2",
						ensure => link,
						replace => true;
                                
			}
		}
		
	}
	default:
     	{
#		notice("$kernel OS not supporting the linkfarm")
	}
  }
}
