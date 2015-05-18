# = Class: sendmailses
#
# Manages Sendmail for SES.
#
#
class sendmailses (
  $smtp_user,
  $smtp_authentication,
  $smtp_password) {

  package { 'sendmail':
    ensure => latest,
  }

  package { 'sendmail-cf':
    ensure => latest,
  }

  package { 'm4':
    ensure => latest,
  }

  service { 'sendmail':
    ensure  => 'running',
    enable  => true,
    require => Package['sendmail'],
  }

  file { '/etc/mail/authinfo':
    owner   => root,
    group   => root,
    mode    => '0444',
    content => template('sendmailses/authinfo.erb'),
    require => Package['sendmail'],
  }

  exec { 'updateauthinfo':
    require     => File['/etc/mail/authinfo'],
    path        => ['/usr/bin', '/usr/sbin'],
    command     => 'makemap hash /etc/mail/authinfo.db < /etc/mail/authinfo',
    subscribe   => File['/etc/mail/authinfo'],
    refreshonly => true,
    notify      => Service['sendmail'],
  }

  file { '/etc/mail/sendmail.mc':
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/sendmailses/sendmail.mc',
    require => Package['sendmail'],
  }

  file { '/etc/mail/sendmail.cf':
    owner => root,
    group => root,
    mode  => '0644',
  }

  exec { 'updatesendmail':
    require     => [File['/etc/mail/sendmail.cf'],
                    File['/etc/mail/sendmail.mc'],
                    Package['m4'],
                    Package['sendmail-cf']],
    path        => ['/usr/bin', '/usr/sbin'],
    command     => 'm4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf',
    subscribe   => File['/etc/mail/sendmail.mc'],
    refreshonly => true,
    notify      => Service['sendmail'],
  }
}
