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
