require 'spec_helper'
describe 'bugzilla', :type => 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os} mostly defaults" do
      let (:facts) do
        facts
      end
      it { should compile }
      it { should contain_class('bugzilla::apache') }
      it { should contain_apache__mod('perl') }
      it { should contain_apache__vhost('bugzilla.example.com').with(
          {
            'ensure' => 'present',
            'docroot' => '/usr/local/share/bugzilla',
          }
      )}
    end
  end
end
