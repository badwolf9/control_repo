# WIKI START Recipe Systemconfig::krb5
## OS :: Redhat ;Ubuntu ;Fedora ; !Solaris; !MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * all linux hosts
#
# h3. Services affected
# * *none*
#
# h3. Files / directories / links affected
# * CREATE : /etc/krb5.conf
#
# h3. What happens
#
#	Installs a valid krb5.conf
# Installs packes needed "user-keytab"
#
###########
# WIKI STOP
class krb5
{
    case $kernel {
        "Linux":
        {
	case $facts['os']['family'] {
		'Debian' : {
			$pam_pkg="libpam-krb5"
            $perl_readkey_pkg="libterm-readkey-perl"
            $perl_digest_pkg="libdigest-hmac-perl"
            $perl_crypt_rijndael_pkg="libcrypt-rijndael-perl"
            $kstart_pkg="kstart"
		}
		# RedHat based systems
		default :{
			$pam_pkg="pam_krb5"
            $perl_readkey_pkg="perl-TermReadKey"
            $perl_digest_pkg="perl-Digest-HMAC"
            $perl_crypt_rijndael_pkg="perl-Crypt-Rijndael"
            $kstart_pkg="kstart"
		}
	}
	package {   "$pam_pkg": ensure => installed, alias => pam_krb5_client }
    # Packages needed for user-keytab. See: https://github.com/isginf/user-keytab
	package {   "$perl_readkey_pkg": ensure => installed }
	package {   "$perl_digest_pkg": ensure => installed }
	package {   "$perl_crypt_rijndael_pkg": ensure => installed }
	package {   "$kstart_pkg": ensure => installed }
    if 'service_kerberos' in $my_classes {
        $krb5conffile = "krb5_krb5.conf"
        } else {
        $krb5conffile = "krb5.conf"
        }   
	 	file { "/etc/krb5.conf":
	 	        owner => "root",
	 	        group => "root",
	 	        mode  => "644",
			content => file("krb5/$krb5conffile"),
	 		require => [ Package[pam_krb5_client] ],
	 		replace => true,
	 		alias => krb5conf,
	 		backup => main,
	 		}
		}	
	default: {
                        notice("$kernel OS not supported for KRB5")
		}
	}
}
