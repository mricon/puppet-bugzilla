require 'spec_helper'
describe 'bugzilla', :type => 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os} mostly defaults" do
      let (:facts) do
        facts
      end
      it { should compile }
      it { should contain_class('bugzilla::install') }

      pkgnames = [
          'gcc-c++',
          'gd-devel',
          'graphviz',
          'patchutils',
          'perl-App-cpanminus',
          'perl-DBD-MySQL',
          'perl-DBD-SQLite',
          'perl-autodie',
          'rst2pdf',
      ]
      pkgnames.each do |pkgname|
          it { should contain_package(pkgname)
              .with_ensure('installed')
          }
      end

      it {
          should contain_file('/usr/local').with(
          {
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          }
      )}
      it { should contain_file('/usr/local/share/bugzilla').with(
          {
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'apache',
            'mode'   => '0750',
          }
      )}
      it { should contain_vcsrepo('/usr/local/share/bugzilla').with(
          {
            'ensure'   => 'present',
            'provider' => 'git',
            'source'   => /https:\/\/github\.com\/bugzilla/,
            'revision' => 'release-5.1.1'
          }
      )}
      it { should contain_exec('perl-Makefile.PL').with(
          {
            'command' => 'perl Makefile.PL',
            'cwd'     => '/usr/local/share/bugzilla',
          }
      )}
      it { should contain_exec('cpanm-installdeps').with(
          {
            'command' => /-l \/usr\/local/,
            'cwd'     => '/usr/local/share/bugzilla',
          }
      )}
      it { should contain_file('/usr/local/share/bugzilla/localconfig').with(
          {
            'ensure' => 'link',
            'target' => '/etc/bugzilla/localconfig',
          }
      )}
      it { should contain_file('/usr/local/share/bugzilla/local').with(
          {
            'ensure' => 'link',
            'target' => '/usr/local',
          }
      )}
      it { should contain_file('/var/lib/bugzilla').with(
          {
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'apache',
            'mode'   => '0750',
          }
      )}
      it { should contain_file('/var/lib/bugzilla/data').with(
          {
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'apache',
            'mode'   => '0770',
          }
      )}
      it { should contain_file('/usr/local/share/bugzilla/data').with(
          {
            'ensure' => 'link',
            'target' => '/var/lib/bugzilla/data',
          }
      )}
      it { should contain_exec('checksetup.pl')
          .with_command('perl checksetup.pl /etc/bugzilla/checksetup_answers')
      }
      it { should contain_exec('selinux-equiv-/usr/local/share/bugzilla')
          .with_command(/-a -e \/usr\/share\/bugzilla/)
      }
      it { should contain_exec('restorecon-/usr/local/share/bugzilla')
          .with_command(/-R \/usr\/local\/share\/bugzilla/)
      }
    end
  end
  on_supported_os.each do |os, facts|
    context "on #{os} installed in /var/www/bugzilla" do
      let (:facts) do
        facts
      end
      facts['testname'] = 'install_var_www'
      it { should compile }
      it { should contain_class('bugzilla::install') }
      it { should contain_file('/var/www/bugzilla')
          .with_group('www')
      }
      it { should contain_exec('perl-Makefile.PL')
          .with_cwd('/var/www/bugzilla')
      }
      it { should contain_exec('cpanm-installdeps').with(
          {
            'command' => /-l \/var\/www\/bugzilla\/local/,
            'cwd'     => '/var/www/bugzilla',
          }
      )}
      it { should contain_vcsrepo('/var/www/bugzilla')
          .with_ensure('present')
          .with_revision('release-5.1.2')
      }
      it {
          should contain_file('/var/www/bugzilla/local')
              .with_ensure('directory')
      }
      it { should contain_file('/var/www/bugzilla/localconfig').with(
          {
            'ensure' => 'link',
            'target' => '/etc/bugzilla/localconfig',
          }
      )}
      it { should contain_exec('selinux-equiv-/var/www/bugzilla')
          .with_command(/-a -e \/usr\/share\/bugzilla/)
      }
      it { should contain_exec('restorecon-/var/www/bugzilla')
          .with_command(/-R \/var\/www\/bugzilla/)
      }
    end
  end
end
