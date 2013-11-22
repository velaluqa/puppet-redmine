# Puppet-redmine

## Usage



```
  class { 'redmine':
    app_root             = '/srv/redmine',
    redmine_source       = 'https://github.com/redmine/redmine.git',
    redmine_revision     = 'origin/2.3-stable',
    redmine_user         = 'deployment',
    db_adapter           = 'pgsql',
    db_name              = 'redminedb',
    db_user              = 'redminedbu',
    db_password          = 'changeme',
    db_host              = 'localhost',
    db_port              = '3306',
    rvm_ruby             = '1.9.3@redmine',
  }
```
### Other class parameters

TODO: add parameter list

## Dependencys

```
dependency "puppetlabs/vcsrepo", ">=0.2.0"
```

## Contribute

Want to help - send a pull request.

## License

This file is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any
later version.

This file is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU Emacs; see the file COPYING. If not, write to the Free
Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.
