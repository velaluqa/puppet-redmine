# == Define: redmine::vhost_nginx
#
# Generates a vhost for redmine in nginx web server configuration
#
# === Parameters
#
# [*port*]
#    port where this vhost should listen
# [*priority*]
#    priority of the site configuration file
# [*serveraliases*]
#    list of aliases of the vhost
# [*root_dir*]
#    root directory of the redmine installation
# [*max_attachment_size*]
#    maximum size of the attachment
#
# === Examples
#
# redmine::vhost_nginx { 'redmine.example.net':
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
define redmine::vhost_nginx(
  $port='80',
  $priority='50',
  $max_attachment_size='20M',
  $serveraliases=[],
  $root_dir,
) {
  nginx::vhost { $title:
    port           => $port,
    priority       => $priority,
    docroot        => undef,
    create_docroot => false,
    template       => 'redmine/nginx_redmine_site.conf.erb',
    options        => {
      'serveraliases'        => $serveraliases,
      'upstream_web'         => "upstream-web-puma-redmine-${title}",
      'upstream_socket_path' => "${root_dir}/current/tmp/sockets/puma.socket",
      'client_max_body_size' => $max_attachment_size,
    }
  }
}
