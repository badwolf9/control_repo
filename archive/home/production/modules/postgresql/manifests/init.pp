
# need to check path for postgres - use alternative.....
class postgresql
{
   case $facts['kernel'] {
           "Linux": {
                if 'service_db_postgresql' in $my_classes {
notify { "Postgresql..." : }
	    file { "/usr/local/bin/clearBssePgLogs.sh":
	                owner => "root",
                        group => "root",
                        mode  => '0755',
                        content => template("postgresql/clearBssePgLogs.erb"),
                        replace => true,
                        backup => main,
              }
	    }
        }
    default: {
	notice("$kernel OS not supported for recipe postgresql")
    }
   }
}

