# == Class: bugzilla::install
#
# Install class for bugzilla
class bugzilla::install inherits bugzilla {
  if $bugzilla::manage_git {
    include ::git
  }

  case $bugzilla::version {
    'latest': {
      $vcsrepo_ensure = 'latest'
      $revision = 'master'
    }
    default: {
      $vcsrepo_ensure = 'present'
      $revision       = $bugzilla::version
    }
  }

  file { $bugzilla::cpan_install_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $bugzilla::install_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => $bugzilla::config::webservergroup,
    mode   => '0750',
  }

  vcsrepo { $bugzilla::install_dir:
    ensure   => $vcsrepo_ensure,
    provider => 'git',
    source   => $bugzilla::source_repo,
    revision => $revision,
    force    => true,
    require  => File[$bugzilla::install_dir],
    notify   => Exec['perl-Makefile.PL'],
  }

  package { [
    'rst2pdf',
    'graphviz',
    'patchutils',
    'gcc-c++',
    'gd-devel',
    'perl-App-cpanminus',
    'perl-DBD-MySQL',
    'perl-DBD-SQLite',
    'perl-autodie',
    ]:
    ensure => installed,
  }

  exec { 'perl-Makefile.PL':
    command => 'perl Makefile.PL',
    path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    cwd     => $bugzilla::install_dir,
    creates => "${bugzilla::install_dir}/Makefile",
    require => [
      Package['gcc-c++'],
      Package['gd-devel'],
      Package['perl-autodie'],
      Package['perl-App-cpanminus'],
    ],
    notify  => Exec['cpanm-installdeps'],
  }

  exec { 'cpanm-installdeps':
    command => "cpanm --installdeps -l ${bugzilla::cpan_install_dir} ${bugzilla::cpanm_flags} .",
    path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    cwd     => $bugzilla::install_dir,
    creates => "${bugzilla::cpan_install_dir}/lib/perl5",
    timeout => 0,
    require => [
      Exec['perl-Makefile.PL'],
      File[$bugzilla::cpan_install_dir],
    ],
    notify  => Exec['checksetup.pl'],
  }

  file { "${bugzilla::install_dir}/localconfig":
    ensure  => link,
    target  => "${bugzilla::config_dir}/localconfig",
    require => [
      File["${bugzilla::config_dir}/localconfig"],
      Exec['cpanm-installdeps'],
    ],
  }

  if ($bugzilla::cpan_install_dir != 'local' and
      $bugzilla::cpan_install_dir != "${bugzilla::install_dir}/local" and
      $bugzilla::cpan_install_dir != '/usr') {
    file { "${bugzilla::install_dir}/local":
      ensure  => link,
      target  => $bugzilla::cpan_install_dir,
      require => Exec['cpanm-installdeps'],
      before  => Exec['checksetup.pl'],
    }
  }

  if $bugzilla::var_dir != $bugzilla::install_dir {
    file { $bugzilla::var_dir:
      ensure => directory,
      owner  => 'root',
      group  => $bugzilla::config::webservergroup,
      mode   => '0750',
    }
    file { "${bugzilla::var_dir}/data":
      ensure  => directory,
      owner   => 'root',
      group   => $bugzilla::config::webservergroup,
      mode    => '0770',
      require => File[$bugzilla::var_dir],
    }
    file { "${bugzilla::install_dir}/data":
      ensure  => link,
      target  => "${bugzilla::var_dir}/data",
      require => File["${bugzilla::var_dir}/data"],
      before  => Exec['checksetup.pl'],
    }
  }

  if $bugzilla::config::extensions {
    $bugzilla::config::extensions.each |String $ext_name, String $ext_source| {
      file { "${bugzilla::install_dir}/extensions/${ext_name}":
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        owner   => 'root',
        group   => $bugzilla::config::webservergroup,
        mode    => '0640',
        source  => $ext_source,
        before  => Exec['checksetup.pl'],
      }
    }
  }

  exec { 'checksetup.pl':
    command     => "perl checksetup.pl ${bugzilla::config_dir}/checksetup_answers",
    path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    cwd         => $bugzilla::install_dir,
    timeout     => 0,
    subscribe   => [
      File["${bugzilla::config_dir}/localconfig"],
      File["${bugzilla::config_dir}/checksetup_answers"],
      File["${bugzilla::install_dir}/localconfig"],
    ],
    require     => [
      Exec['perl-Makefile.PL'],
      File["${bugzilla::install_dir}/localconfig"],
      File["${bugzilla::config_dir}/checksetup_answers"],
    ],
    refreshonly => true,
    notify      => Exec["restorecon-${bugzilla::install_dir}"],
  }

  if $bugzilla::selinux_equiv_dir {
    exec { "selinux-equiv-${bugzilla::install_dir}":
      path    => '/usr/bin:/usr/sbin:/bin:/sbin',
      command => "semanage fcontext -a -e ${bugzilla::selinux_equiv_dir} ${bugzilla::install_dir}",
      unless  => "semanage fcontext -l | ( egrep '${bugzilla::install_dir} = ${bugzilla::selinux_equiv_dir}' >/dev/null)",
      require => Exec['checksetup.pl'],
    } ~>
    exec { "restorecon-${bugzilla::install_dir}":
      path        => '/usr/bin:/usr/sbin:/bin:/sbin',
      command     => "restorecon -R ${bugzilla::install_dir}",
      refreshonly => true,
    }
  }

}
