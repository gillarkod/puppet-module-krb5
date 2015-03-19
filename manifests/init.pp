class krb5 (
    $logging_default      = 'FILE:/var/log/krb5libs.log',
    $logging_kdc          = 'FILE:/var/log/krb5kdc.log',
    $logging_admin_server = 'FILE:/var/log/kadmind.log',
    $default_realm        = undef,
    $dns_lookup_realm     = undef,
    $dns_lookup_kdc       = undef,
    $ticket_lifetime      = undef,
    $default_keytab_name  = undef,
    $forwardable          = undef,
    $proxiable            = undef,
    $realms               = undef,
    $appdefaults          = undef,
    $domain_realm         = undef,
    $rdns                 = undef,
    $package              = 'USE_DEFAULTS',
    $package_adminfile    = undef,
    $package_provider     = undef,
    $package_source       = undef,
    $krb5conf_file        = '/etc/krb5.conf',
    $krb5conf_ensure      = 'present',
    $krb5conf_owner       = 'root',
    $krb5conf_group       = 'root',
    $krb5conf_mode        = '0644',
) {
  if $package == 'USE_DEFAULTS' {
    case $::osfamily {
      'RedHat': {
        $package_real = [ 'krb5-libs', 'krb5-workstation' ]
      }
      'Suse': {
        $package_real = [ 'krb5', 'krb5-client' ]
      }
      'Solaris': {
        $package_real = [ 'SUNWkrbr', 'SUNWkrbu' ]
      }
      'Debian': {
        $package_real = 'krb5-user'
      }
      default: {
        fail("krb5 only supports default package names for Debian, RedHat, Suse and Solaris. Detected osfamily is <${::osfamily}>. Please specify package name with the \$package variable.")
      }
    }
  } else {
    $package_real = $package
  }

  if $package_adminfile != undef {
    Package {
      adminfile => $package_adminfile,
    }
  }

  if $package_provider != undef {
    Package {
      provider => $package_provider,
    }
  }

  if $package_source != undef {
    Package {
      source => $package_source,
    }
  }

  package{ $package_real:
    ensure  => present,
  }

  file{ 'krb5conf':
    path    => $krb5conf_file,
    ensure  => $krb5conf_ensure,
    owner   => $krb5conf_owner,
    group   => $krb5conf_group,
    mode    => $krb5conf_mode,
    content => template('krb5/krb5.conf.erb'),
  }

  if $::osfamily == 'Solaris' {
    file { 'krb5directory' :
      ensure  => directory,
      path    => '/etc/krb5',
      owner   => $krb5conf_owner,
      group   => $krb5conf_group,
    }

    file { 'krb5link' :
      ensure  => link,
      path    => '/etc/krb5/krb5.conf',
      target  => $krb5conf_file,
      require => File['krb5directory'],
    }
  }
}
