# Edit local /etc/hosts files to resolve some hostnames used on your application.
host { 'localhost.localdomain':
    ensure => 'present',
    target => '/etc/hosts',
    ip => '127.0.0.1',
    host_aliases => ['localhost','memcached','mysql','redis','sphinx']
}

# Adding EPEL repo. We'll use later to install Redis class.
class { 'epel': }

# Memcached server (12MB)
class { "memcached": memcached_port => '11211', maxconn => '2048', cachesize => '12', }

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

# PhpMyAdmin
class { 'phpmyadmin': }

# Imagick
class { 'imagemagick': }

include nginx
nginx::file { 'default.conf':
    source => 'puppet:///modules/nginx/php.conf.inc',
}

# PHP useful packages. Pending TO-DO: Personalize some modules and php.ini directy on Puppet recipe.
php::ini {
	'/etc/php.ini':
        display_errors	=> 'On',
        short_open_tag	=> 'Off',
        memory_limit	=> '256M',
        date_timezone	=> 'Europe/Minsk'
}
include php::cli
include php::fpm::daemon
php::fpm::conf { 'www':
    listen  => '127.0.0.1:9001',
    user    => 'vagrant',
    # For the user to exist
    require => Package['nginx'],
}
php::module { [ 'devel', 'pear', 'mysql', 'mbstring', 'xml', 'gd', 'tidy', 'pecl-apc', 'pecl-memcache', 'pecl-imagick']: }

# PHPUnit
exec { '/usr/bin/pear upgrade pear':
    require => Package['php-pear'],
    timeout => 0
}

define discoverPearChannel {
    exec { "/usr/bin/pear channel-discover $name":
        onlyif => "/usr/bin/pear channel-info $name | grep \"Unknown channel\"",
        require => Exec['/usr/bin/pear upgrade pear'],
        timeout => 0
    }
}
discoverPearChannel { 'pear.phpunit.de': }
discoverPearChannel { 'components.ez.no': }
discoverPearChannel { 'pear.symfony-project.com': }
discoverPearChannel { 'pear.symfony.com': }

exec { '/usr/bin/pear install --alldeps pear.phpunit.de/PHPUnit':
    onlyif => "/usr/bin/pear info phpunit/PHPUnit | grep \"No information found\"",
    require => [
        Exec['/usr/bin/pear upgrade pear'],
        DiscoverPearChannel['pear.phpunit.de'],
        DiscoverPearChannel['components.ez.no'],
        DiscoverPearChannel['pear.symfony-project.com'],
        DiscoverPearChannel['pear.symfony.com']
    ],
    user => 'root',
    timeout => 0
}