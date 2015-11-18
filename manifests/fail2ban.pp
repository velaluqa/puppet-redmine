# == Define: redmine::fail2ban
#
# Fail2ban configuration for redmine. NOTE: name of the resource is
# restricted to 29 - len(fail2ban-rm-) characters => 17
# characters. This is due to a limit on iptable chain names.
#
# === Parameters
#
# [*root_dir*]
#   root directory
# [*ports*]
#    optional port list - defaults to standard http and https
# [*bantime*]
#    see fail2ban::jail
# [*maxretry*]
#    see fail2ban::jail
#
# === Examples
#
# redmine::fail2ban { 'redmine.example':
#   root_dir => '/srv/www/redmine.example.net',
# }
#
# === Authors
#
# Braiins Systems s.r.o.
#
# === Copyright
#
# Copyright 2015 Braiins Systems s.r.o.
#
define redmine::fail2ban(
  $port=['80', '443'],
  $bantime=15,
  $maxretry=3,
  $serveraliases=[],
  $root_dir,
) {
  $fail2ban_name = "rm-${title}"
  # Check the supplied title to prevent exceeding the iptables chain name limit
  if size($title) > 17 {
    fail("redmine::fail2ban - title '${title}' longer than 17 characters, iptables chain name: '${fail2ban_name}' would exceed iptables limit, make the resource name shorter!")
  }
  fail2ban::filter { $fail2ban_name:
    filterfailregex => 'Failed login for \'.*\' from <HOST> .*$',
  } ->
  # The jail uses the default iptables multiport ban action
  fail2ban::jail { $fail2ban_name:
    logpath  => "${root_dir}/current/log/production.log",
    bantime  => $bantime,
    maxretry => $maxretry,
    port     => $port,
    filter   => $fail2ban_name,
  }
}
