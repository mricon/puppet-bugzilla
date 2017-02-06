
class bugzilla::database::mysql {
  if $bugzilla::config::db_driver == 'mysql' {
    if $bugzilla::manage_db {
      include ::mysql::server
    }

    if $bugzilla::db_exported {
      @@mysql::db { "bugzilla_${::fqdn}":
        user     => $bugzilla::config::db_user,
        password => $bugzilla::config::db_pass,
        dbname   => $bugzilla::config::db_name,
        host     => $::ipaddress,
        tag      => $bugzilla::db_tag,
      }
    } else {
      mysql::db { 'bugzilla':
        ensure   => present,
        user     => $bugzilla::config::db_user,
        password => $bugzilla::config::db_pass,
        dbname   => $bugzilla::config::db_name,
        host     => $::ipaddress,
      }
    }
  }
}
