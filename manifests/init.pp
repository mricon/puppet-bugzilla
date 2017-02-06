# == Class: bugzilla
#
# Main bugzilla init class
class bugzilla (
  Boolean                  $manage_git          = $bugzilla::params::manage_git,
  Boolean                  $manage_db           = $bugzilla::params::manage_db,
  # local db or exported def?
  Boolean                  $db_exported         = $bugzilla::params::db_exported,
  Optional[String]         $db_tag              = $bugzilla::params::db_tag,

  String                   $version             = $bugzilla::params::version,

  Pattern['^\/']           $install_dir         = $bugzilla::params::install_dir,
  Pattern['^\/']           $config_dir          = $bugzilla::params::config_dir,
  Pattern['^\/']           $var_dir             = $bugzilla::params::var_dir,
  String                   $source_repo         = $bugzilla::params::source_repo,
  String                   $cpan_install_dir    = $bugzilla::params::cpan_install_dir,
  String                   $cpanm_flags         = $bugzilla::params::cpanm_flags,
  Optional[Pattern['^\/']] $selinux_equiv_dir   = $bugzilla::params::selinux_equiv_dir,
  Boolean                  $manage_apache       = $bugzilla::params::manage_apache,
  Boolean                  $apache_manage_vhost = $bugzilla::params::apache_manage_vhost,
  Optional[String]         $apache_vhost_name   = $bugzilla::params::apache_vhost_name,

) inherits bugzilla::params {

  # we run checksetup as part of the install step, which
  # requires a config file present, so this is a bit confusingly
  # backwards than in most modules
  anchor { "${module_name}::begin": } ->
  class { "${module_name}::config": } ->
  class { "${module_name}::database::mysql": } ->
  class { "${module_name}::apache": } ->
  class { "${module_name}::install": } ->
  anchor { "${module_name}::end": }
}
