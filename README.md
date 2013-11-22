# Puppet-redmine

## Usage

```
  class {
    'redmine:
      redmine_domain => 'redmine.foobar.fr',
      redmine_dbtype => 'mysql',
      redmine_dbname => $redmine_dbname,
      redmine_dbuser => $redmine_dbuser,
      redmine_dbpwd  => $redmine_dbpwd,
      ldap_enabled   => false,
  }
```
### Other class parameters

TODO: add parameter list

## Dependencys

TODO: add dependencies

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
