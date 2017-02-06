# == Class: bugzilla::params
#
# This is a container class with default parameters for bugzilla class
class bugzilla::params {
  $manage_git          = true
  $manage_db           = true
  # do we create the db locally or export a definition?
  # requires that we set db_tag
  $db_exported         = false
  $db_tag              = undef

  $version             = 'release-5.1.1'
  $install_dir         = '/usr/local/share/bugzilla'
  $config_dir          = '/etc/bugzilla'
  $var_dir             = '/var/lib/bugzilla'
  $source_repo         = 'https://github.com/bugzilla/bugzilla.git'

  $cpan_install_dir    = '/usr/local'
  $cpanm_flags         = '-n --with-all-features --without-feature mod_perl --without-feature oracle --without-feature sqlite --without-feature mysql --without-feature pg'
  # Set to undef if you don't want selinux bits touched
  $selinux_equiv_dir   = '/usr/share/bugzilla'

  # Should we manage apache bits?
  $manage_apache       = true

  # Set to false if you want to manage your own vhost defs
  $apache_manage_vhost = true
  $apache_vhost_name   = 'bugzilla.example.com'
}
