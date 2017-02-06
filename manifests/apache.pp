# == Class: bugzilla::apache
#
# Apache bits for bugzilla
class bugzilla::apache inherits bugzilla {
  if $bugzilla::manage_apache {
    include ::apache
    apache::mod { 'perl':
      before => Exec['perl-Makefile.PL'],
    }

    if $bugzilla::apache_manage_vhost {
      apache::vhost { $bugzilla::apache_vhost_name:
        ensure         => present,
        port           => '80',
        docroot        => $bugzilla::install_dir,
        manage_docroot => false,
        setenvif       => 'X-Forwarded-Proto https HTTPS=on',
        directories    => [
          {
            path           => $bugzilla::install_dir,
            addhandlers    => [
              {
                handler    => 'cgi-script',
                extensions => '.cgi',
              },
            ],
            directoryindex => 'index.cgi index.html',
            options        => [
              'Indexes',
              'ExecCGI',
              'FollowSymLinks',
              'SymLinksIfOwnerMatch',
            ],
            allow_override => 'All',
          }
        ],
      }
    } else {
      apache::vhost { $bugzilla::apache_vhost_name:
        ensure => absent,
      }
    }
  }
}
