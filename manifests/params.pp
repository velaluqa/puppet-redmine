# Class:: redmine::params
#
#
class redmine::params {
  $app_root           = '/srv/redmine'
  $redmine_sources    = 'https://github.com/redmine/redmine.git'
  $redmine_branch     = '2.3-stable'
  $redmine_user       = 'deployment'
  $db_adapter         = 'mysql'
  $db_name            = 'redminedb'
  $db_user            = 'redminedbu'
  $db_password        = 'changeme'
  $db_host            = 'localhost'
  $db_port            = '3306'
  $ldap_enabled       = false
  $ldap_host          = 'ldap.domain.com'
  $ldap_base          = 'dc=domain,dc=com'
  $ldap_uid           = 'uid'
  $ldap_port          = '636'
  $ldap_method        = 'ssl'
  $ldap_bind_dn       = ''
  $ldap_bind_password = ''
  $rvm_ruby           = ''

} # Class:: redmine::params
