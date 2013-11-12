# == Class: redmine
#
# === Parameters
#
# TODO: Add parameters
#
# === Examples
#
# TODO: Add examples
#
# === Authors
#
# Arthur Leonard Andersen <leoc.git@gmail.com>
#
# === Copyright
#
# See LICENSE file, Arthur Leonard Andersen (c) 2013

# Class:: redmine
#
#
class redmine(
  $app_root             = '/srv/redmine',
  $redmine_sources      = 'https://github.com/redmine/redmine.git',
  $redmine_branch       = '2.3-stable',
  $redmine_user         = 'deployment',
  $db_adapter           = 'mysql',
  $db_name              = 'redminedb',
  $db_user              = 'redminedbu',
  $db_password          = 'changeme',
  $db_host              = 'localhost',
  $db_port              = '3306',
  $ldap_enabled         = false,
  $ldap_host            = 'ldap.domain.com',
  $ldap_base            = 'dc=domain,dc=com',
  $ldap_uid             = 'uid',
  $ldap_port            = '636',
  $ldap_method          = 'ssl',
  $ldap_bind_dn         = '',
  $ldap_bind_password   = '',
  $rvm_ruby             = '',
) {
  if $rvm_ruby != '' {
    $rvm_prefix     = "source /usr/local/rvm/scripts/rvm; rvm use --create ${rvm_ruby} > /dev/null; "
  } else {
    $rvm_prefix     = ''
  }

  $without_gems = $db_adapter ? {
    mysql => 'development test postgres',
    pgsql => 'development test mysql'
  }

  case $::osfamily {
    'Debian': {
      case $db_adapter {
        'mysql': {
          if !defined(Package['libmysql++-dev']) {
            package { 'libmysql++-dev':
              ensure   => installed,
              before => Exec['redmine-bundle'],
            }
          }
          if !defined(Package['libmysqlclient-dev']) {
            package { 'libmysqlclient-dev':
              ensure   => installed,
              before => Exec['redmine-bundle'],
            }
          }
        }
        'pgsql': {
          if !defined(Package['libpq-dev']) {
            package { 'libpq-dev':
              ensure   => installed,
              before => Exec['redmine-bundle'],
            }
          }
          if !defined(Package['postgresql-client']) {
            package { 'postgresql-client':
              ensure   => installed,
              before => Exec['redmine-bundle'],
            }
          }
        }
      }

      if !defined(Package['libmagickcore-dev']) {
        package { 'libmagickcore-dev':
          ensure   => latest,
          before => Exec['redmine-bundle'],
        }
      }
      if !defined(Package['libmagickwand-dev']) {
        package { 'libmagickwand-dev':
          ensure   => latest,
          before => Exec['redmine-bundle'],
        }
      }
    } # Debian pre-requists
    'Redhat': {
      $db_packages = $db_adapter ? {
        mysql => ['mysql-devel'],
        pgsql => ['postgresql-devel'],
      }

      case $deb_adapter {
        'mysql': {
          if !defined(Package['mysql-devel']) {
            package { 'mysql-devel':
              ensure   => installed,
              before => Exec['redmine-bundle'],
            }
          }
        }
        'pgsql': {
          if !defined(Package['postgresql-devel']) {
            package { 'postgresql-devel':
              ensure   => installed,
              before => Exec['redmine-bundle'],
            }
          }
        }
      }

      if !defined(Package['ImageMagick']) {
        package { 'ImageMagick':
          ensure   => latest,
          provider => yum,
          before => Exec['redmine-bundle'],
        }
      }
    } # Redhat pre-requists
    default: {
      err "${::osfamily} not supported yet"
    }
  }

  puma::app { 'redmine':
    app_root => $app_root,
    app_user => $redmine_user,
    db_adapter => $db_adapter,
    db_user => $db_user,
    db_password => $db_password,
    db_host => $db_host,
    db_port => $db_port,
    rvm_ruby => $rvm_ruby,
  }

  exec { 'redmine-checkout':
    path => '/bin:/usr/bin',
    unless => "[ -d '${app_root}/current' ]",
    command => "git clone ${redmine_sources} ${app_root}/current",
    require => File[$app_root],
    user => $redmine_user,
    group => $redmine_user,
  }

  file { "${app_root}/current/config/database.yml":
    ensure => link,
    target => "${app_root}/shared/config/database.yml",
    require => Exec['redmine-checkout'],
  }

  file { "${app_root}/current/config/puma.rb":
    ensure => link,
    target => "${app_root}/shared/config/puma.rb",
    require => Exec['redmine-checkout'],
  }

  file { "${app_root}/current/tmp":
    ensure => link,
    force => true,
    target => "${app_root}/shared/tmp",
    require => Exec['redmine-checkout'],
  }

  file { "${app_root}/current/Gemfile.local":
    content => "gem 'puma'",
    before => Exec['redmine-bundle']
  }

  exec { 'redmine-update':
    path => '/bin:/usr/bin',
    command => "bash -c 'cd ${app_root}/current; git fetch'",
    require => Exec["redmine-checkout"],
    user => $redmine_user,
    group => $redmine_user
  }

  exec { "redmine-upgrade":
    path => "/bin:/usr/bin",
    onlyif => "bash -c 'cd ${app_root}/current; git diff HEAD..origin/${redmine_branch} | grep -q ^---'",
    command => "bash -c 'cd ${app_root}/current; git checkout db/schema.rb; git checkout origin/${redmine_branch}'",
    require => Exec['redmine-update'],
    user => $redmine_user,
    group => $redmine_user
  }

  exec { 'redmine-bundle':
    path => '/bin:/usr/bin',
    command => "bash -c '${rvm_prefix}cd ${app_root}/current; bundle --without ${without_gems} || bundle update'",
    unless => "bash -c '${rvm_prefix}cd ${app_root}/current; bundle check'",
    require => Exec['redmine-upgrade'],
    notify => Service['redmine'],
    user => $redmine_user,
    group => $redmine_user,
    timeout => 600,
  }

  exec { "redmine-migrate":
    path => "/bin:/usr/bin",
    unless => "bash -c '${rvm_prefix}cd ${app_root}/current; RAILS_ENV=production bundle exec rake db:abort_if_pending_migrations'",
    command => "bash -c '${rvm_prefix}cd ${app_root}/current; RAILS_ENV=production bundle exec rake db:migrate'",
    require => [ Exec['redmine-bundle'], File["${app_root}/current/config/database.yml"] ],
    notify => Service["redmine"],
    user => $redmine_user,
    group => $redmine_user,
    timeout => 600,
  }

  exec { "redmine-configure":
    require => Exec['redmine-migrate'],
    path => "/bin:/usr/bin",
    command => "bash -c '${rvm_prefix}cd ${app_root}/current; RAILS_ENV=production bundle exec rake generate_secret_token; REDMINE_LANG=en RAILS_ENV=production bundle exec rake redmine:load_default_data'; touch ${app_root}/.configured",
    unless => "[ -f ${app_root}/.configured ]",
    user => $redmine_user,
    group => $redmine_user,
    timeout => 600,
  }
} # Class:: redmine
