require 'spec_helper'
describe 'bugzilla', :type => 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os} mostly defaults" do
      let (:facts) do
        facts
      end
      it { should compile }
      it { should contain_class('bugzilla::config') }

      it { should contain_file('/etc/bugzilla')
          .with_ensure('directory')
          .with_owner('root')
          .with_group('apache')
          .with_mode('0750')
      }
      it { should contain_file('/etc/bugzilla/localconfig')
          .with_ensure('file')
          .with_owner('root')
          .with_group('apache')
          .with_mode('0640')
          .with_content(/\$webservergroup = 'apache';/)
          .with_content(/\$db_driver = 'sqlite';/)
          .with_content(/\$site_wide_secret = 'bogusbogus/)
      }
      it { should contain_file('/etc/bugzilla/checksetup_answers')
          .with_ensure('file')
          .with_owner('root')
          .with_group('apache')
          .with_mode('0640')
          .with_content(/'ADMIN_LOGIN'\s*=>\s*'administrator',/)
          .with_content(/'ADMIN_EMAIL'\s*=>\s*'bogus@example.com',/)
          .with_content(/'ADMIN_PASSWORD'\s*=>\s*'bogusbupkes',/)
          .with_content(/'ADMIN_REALNAME'\s*=>\s*'Bogus Bupkes',/)
      }
    end
  end
end
