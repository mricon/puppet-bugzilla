# == Class: bugzilla::config
#
# Bugzilla localconfig configuration parameters
class bugzilla::config (
  Integer[0, 1]            $create_htaccess          = 1,
  String                   $webservergroup           = 'apache',
  Integer[0, 1]            $use_suexec               = 0,
  Enum['mysql','sqlite']   $db_driver                = 'sqlite',
  String                   $db_host                  = 'localhost',
  String                   $db_name                  = 'bugs',
  String                   $db_user                  = 'bugs',
  Optional[String]         $db_pass                  = undef,
  Integer[0, 65535]        $db_port                  = 0,
  Optional[Pattern['^\/']] $db_sock                  = undef,
  Integer[0, 1]            $db_check                 = 0,
  Optional[String]         $db_mysql_ssl_ca_file     = undef,
  Optional[String]         $db_mysql_ssl_ca_path     = undef,
  Optional[String]         $db_mysql_ssl_client_cert = undef,
  Optional[String]         $db_mysql_ssl_client_key  = undef,
  Integer[0, 1]            $index_html               = 0,
  Optional[Pattern['^\/']] $interdiffbin             = '/bin/interdiff',
  Optional[Pattern['^\/']] $diffpath                 = '/bin',
  Optional[Pattern['^\/']] $font_file                = undef,
  Optional[String]         $webdotbase               = undef,

  String[64]               $site_wide_secret         = undef,
  Integer[-1]              $apache_size_limit        = 250000,

  # checksetup answers
  String                   $admin_login              = undef,
  Pattern['.*@.*']         $admin_email              = undef,
  String                   $admin_realname           = undef,
  String[8]                $admin_password           = undef,

  # Extensions
  Optional[Hash]           $extensions               = undef,

) inherits bugzilla {

  if ! $site_wide_secret {
    fail('You MUST set site_wide_secret with minimal length of 64 chars')
  }

  file { $bugzilla::config_dir:
    ensure => directory,
    owner  => 'root',
    group  => $webservergroup,
    mode   => '0750',
  }

  file { "${bugzilla::config_dir}/localconfig":
    ensure  => file,
    owner   => 'root',
    group   => $webservergroup,
    mode    => '0640',
    content => template("${module_name}/localconfig.erb"),
    require => File[$bugzilla::config_dir],
  }

  file { "${bugzilla::config_dir}/checksetup_answers":
    ensure  => file,
    owner   => 'root',
    group   => $webservergroup,
    mode    => '0640',
    content => template("${module_name}/checksetup_answers.erb"),
    require => File[$bugzilla::config_dir],
  }
}

