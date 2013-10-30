define redmine::plugin::rake {
  if $redmine::rvm_ruby != '' {
    $rvm_prefix     = "source /usr/local/rvm/scripts/rvm; rvm use --create ${redmine::rvm_ruby} > /dev/null; "
  } else {
    $rvm_prefix     = ''
  }

  exec { $name:
    path => "/usr/bin:/bin",
    user => $redmine::redmine_user,
    command => "bash -c '${rvm_prefix}cd ${redmine::app_root}/current; RAILS_ENV=production bundle exec rake ${name}'",
    refreshonly => true,
  }
}

define redmine::plugin
(
  $git_repo = undef,
  $git_branch = "master",
  $git_tag = undef,
  $migrate = false,
  $rake = [],
)
{
  if $redmine::rvm_ruby != '' {
    $rvm_prefix     = "source /usr/local/rvm/scripts/rvm; rvm use --create ${redmine::rvm_ruby} > /dev/null; "
  } else {
    $rvm_prefix     = ''
  }

  if($git_tag == undef) {
    $git_ref = "origin/${git_branch}"
  } else {
    $git_ref = $git_tag
  }

  $redmine_dir = "${redmine::app_root}/current"
  $plugins_dir = "${redmine_dir}/plugins"
  $plugin_dir = "${redmine_dir}/plugins/${name}"

  exec { "clone-${name}-plugin":
    path => "/usr/bin:/bin",
    user => $redmine::redmine_user,
    cwd => $plugins_dir,
    command => "git clone ${git_repo} ${name}",
    creates => $plugin_dir,
    require => Exec["redmine-configure"],
    notify => Service['redmine'],
  }

  ->

  exec { "checkout-${name}-ref":
    path => "/usr/bin:/bin",
    user => $redmine::redmine_user,
    cwd => $plugin_dir,
    command => "git checkout db/schema.rb; git checkout ${git_ref}",
    onlyif => "git fetch; git diff HEAD..origin/${git_ref} | grep -q ^---",
    notify => Service['redmine'],
  }

  ->

  exec { "migrate-${name}-plugin":
    path => "/usr/bin:/bin",
    user => $redmine::redmine_user,
    command => $migrate ? {
      true  => "bash -c '${rvm_prefix}cd ${redmine_dir}; RAILS_ENV=production bundle exec rake db:migrate'",
      false => "/bin/true",
    },
    refreshonly => true,
    notify => Service['redmine'],
  }

  ->

  redmine::plugin::rake { $rake:
    subscribe => [ Exec["clone-${name}-plugin"], Exec["checkout-${name}-ref"] ],
    require => [ Exec["migrate-${name}-plugin"], Exec["checkout-${name}-ref"] ],
  }
}
