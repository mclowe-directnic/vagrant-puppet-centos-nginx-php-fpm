# Edit local /etc/hosts files to resolve some hostnames used on your application.
host { 'localhost.localdomain':
    ensure => 'present',
    target => '/etc/hosts',
    ip => '127.0.0.1',
    host_aliases => ['localhost','mysql']
}

# Miscellaneous packages.
$misc_packages = ['vim-enhanced','telnet','zip','unzip','git']
package { $misc_packages: ensure => latest }
class { "ntp": autoupdate => true }

# Iptables (Firewall) package and rules to allow ssh, http, https and dns services.
class iptables {
	package { "iptables":
		ensure => present
	}

	service { "iptables":
		require => Package["iptables"],
		hasstatus => true,
		status => "true",
		hasrestart => false,
	}

	file { "/etc/sysconfig/iptables":
		owner   => "root",
		group   => "root",
		mode    => 600,
		replace => true,
		ensure  => present,
		source  => "/vagrant/files/iptables.txt",
		require => Package["iptables"],
		notify  => Service["iptables"],
	}
}
class { 'iptables': }

# MySQL packages and some configuration to automatically create a new database.
class { 'mysql': }

class { 'mysql::server':
	config_hash => {
		root_password 	=> '1234',
		log_error 	=> '/logs/mysql',
		default_engine	=> 'InnoDB'
	}
}

Database {
	require => Class['mysql::server'],
}

#database { 'myDB':
#  ensure => 'present',
#  charset => 'utf8',
#}

#database_user { 'myUser@localhost':
#  password_hash => mysql_password('myPassword')
#}

#database_grant { 'myUser@localhost/myDB':
#  privileges => ['all'] ,
#}

$additional_mysql_packages = [ "mysql-devel", "mysql-libs" ]
package { $additional_mysql_packages: ensure => present }