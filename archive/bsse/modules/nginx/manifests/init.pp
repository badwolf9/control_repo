# WIKI START Recipe Systemconfig::nginx
## OS :: RedHat;Ubuntu;Fedora;!Solaris;
######################################
#
# h3. Host / Service groups affected
#
# * *service-nginx* 
#
# h3. Services affected
# * *nginx* 
#
# h3. Files / directories / links affected
# * DEPLOY : /etc/nginx/nginx.conf
# * DEPLOY : /etc/nginx/ssl.conf
# * DEPLOY : /etc/nginx/conf.d/*
#
# h3. What happens
#
# * Deploys Nginx configuration files
# * Deploys Server keys and certificates
#
###########
# WIKI STOP
class nginx {

    if "service_nginx" in $my_classes {
	file {
		"/etc/nginx":
		ensure => directory,
		owner => "root",
		group => "root",
		mode  => '0755',
	}    
	file {
		"/etc/pki/tls":
		ensure => directory,
		owner => "root",
		group => "root",
		mode  => '0755',
	}
	file {
		"/etc/nginx/nginx.conf":
		owner => "root",
		group => "root",
		mode  => '0644',
		content  => epp('nginx/nginx.conf.epp' , { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], }),
                replace => true,
                alias => nginxconf,
                backup => main,
	}
	file {
		"/etc/nginx/ssl.conf":
		owner => "root",
		group => "root",
		mode  => '0644',
		content  => file("nginx/ssl.conf"),
                replace => true,
                alias => nginxssl,
                backup => main,
	}
	file {
		"/etc/nginx/conf.d":
		ensure => directory,
		owner => "root",
		group => "root",
		mode  => '0755',
		source  => "puppet:///modules/nginx/conf.d",
		recurse  => true,
		purge => true,
		replace => true,
                alias => nginxconfigs,
	}
	file {
		"/etc/pki/tls/certs/":
		ensure => directory,
		owner => "root",
		group => "root",
		mode  => '0750',
		source  => "puppet:///modules/nginx/certs",
		recurse  => true,
		purge => true,
		replace => true,
                alias => nginxcerts,
	}
	service { "nginx":
       		ensure => running,
       		enable => true,
       		subscribe  => File[[nginxconf],[nginxssl],[nginxconfigs],[nginxcerts]],
       	}
  }
}
