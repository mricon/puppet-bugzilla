# Bugzilla

[![Build Status](https://travis-ci.org/mricon/puppet-bugzilla.svg?branch=master)]
(https://travis-ci.org/mricon/puppet-bugzilla)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup](#setup)
4. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview
Puppet module to manage Bugzilla installation and configuration.

## Module Description
This module installs and configures [Bugzilla](https://www.bugzilla.org/)
version 5 (though other versions will probably work, too). It tries to
avoid the dependency hell of depending on 3,000 perl packages provided by the
distribution by relying on cpan-module installation scripts provided by
bugzilla itself. It installs them locally to a (configurable) location where
the modules do not clash with the rest of the distribution but provide the
codebase required by bugzilla.

## Setup
There are a few things you HAVE to set up to get going with Bugzilla, such as
who will be the administrator and what the "site_wide_secret" should be (it's
a random string at least 64 characters long that will be used to hash client
cookies and other data).

It's expected that this module will be used with hiera, so the quickest way to
configure it for your environment is to add it to your Puppetfile:

```
mod 'mricon-bugzilla'
```

The minimal configuration bits that should go into hiera are:

```yaml
bugzilla::config::site_wide_secret: '[64-char random string]'
bugzilla::config::admin_login: 'administrator'
bugzilla::config::admin_email: 'administrator@example.com'
bugzilla::config::admin_password: 'somepassword'
bugzilla::config::admin_realname: 'Bugzilla Administrator'
```

Without the above, the module will refuse to run.

You should probably configure your database settings and hostname as well.
Double-check the latest version, too, as you will probably want to use the
latest release

```yaml
bugzilla::config::db_driver: 'mysql'
bugzilla::config::db_host: 'x.x.x.x'
bugzilla::config::db_name: 'bugs'
bugzilla::config::db_user: 'bugs'
bugzilla::config::db_pass: 'somepassword'

bugzilla::apache_vhost_name: 'bugzilla.example.com'
bugzilla::version: 'release-5.1.1'
```

### Initial run
**The initial run will take a LONG time**, as bugzilla will be cloning the git
repository, then downloading and installing a lot of CPAN modules required by
the version of bugzilla. After the 

## Reference
### bugzilla

#### `manage_git`

Whether to manage git installation (needed to clone the bugzilla repository).

Default: `true`

#### `manage_db`

Whether to manage database setup and/or export (see more below).

Default: `true`

#### `db_exported`

If managing the db, is the db configuration exported?

Default: `false`

#### `db_tag`

If the database is exported, set the tag to be "caught" by the managing
server.

Default: `undef`

#### `version`

Bugzilla version to install. Must match the tag in the bugzilla repository.

Default: `release-5.1.1`

#### `install_dir`

Location where the bugzilla tree should be cloned.

Default: `/usr/local/share/bugzilla`

#### `config_dir`

Where the configuration files should be kept.

Default: `/etc/bugzilla`

#### `var_dir`

Where the local data should be kept (the `data` dir).

Default: `/var/lib/bugzilla`

#### `source_repo`

Where to clone the bugzilla tree from. If you must carry local changes that
cannot be put into an extension, you can use your own repo location here.

Default: upstream bugzilla on github

#### `cpan_install_dir`

Where to install CPAN modules.

Default: `/usr/local`

#### `cpanm_flags`

You may tweak the flags passed to the cpanm command.

Default: (see source)


#### `selinux_equiv_dir`

If for some bizarre reason you disabled your SELinux, you can set this to
`undef` to prevent the module from setting equivalency to the bugzilla
location defined by the upstream policy (`/usr/share/bugzilla`).

Default: `/usr/share/bugzilla`

#### `manage_apache`

Set this to false if you don't want to manage apache at all.

Default: `true`

#### `apache_manage_vhost`

When set to true, the module will set up a cookie-cutter vhost for you that is
acceptable for most standalone configurations.

Default: `true`

#### `apache_vhost_name`

The name of the vhost to use.

Default: `bugzilla.example.com`

### bugzilla::config

Most of these correspond directly to settings in the `localconfig`
configuration file. Refer to the comments there for full details

#### `create_htaccess`
Default: `1`

#### `webservergroup`
Default: `apache`

#### `use_suexec`
Default: `0`

#### `db_driver`
Default: `sqlite`

#### `db_host`
Default: `localhost`

#### `db_name`
Default: `bugs`

#### `db_user`
Default: `bugs`

#### `db_pass`
Default: `undef`

#### `db_port`
Default: `0`

#### `db_sock`
Default: `undef`

#### `db_check`
Default: `0`

#### `db_mysql_ssl_ca_file`
#### `db_mysql_ssl_ca_path`
#### `db_mysql_ssl_client_cert`
#### `db_mysql_ssl_client_key`
Default: `undef`

#### `index_html`
Default: `0`

#### `interdiffbin`
Default: `/bin/interdiff`

#### `diffpath`
Default: `/bin`

#### `font_file`
Default: `undef`

#### `webdotbase`
Default: `undef`

#### `site_wide_secret`
Default: `undef`

#### `apache_size_limit`
Default: `250000`

#### `admin_login`
#### `admin_email`
#### `admin_realname`
#### `admin_password`
Default: `undef`

#### `extensions`

Most template or other behaviour configuration changes are best done via
extensions, so use this hash to define the name of the extension and the path
where the directory with full extension contents should be found.

Example hiera:

```yaml
bugzilla::config::extensions:
  'Example': 'puppet:///modules/profile/bugzilla/extensions/Example'
```

The directory will be recursively copied in place.

Default: `undef`

## Limitations

Written and tested for CentOS 7 only, and will require some hacking to make it
work on other distros (patches welcome).
