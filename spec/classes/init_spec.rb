require 'spec_helper'
describe 'bugzilla', :type => 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os} mostly defaults" do
      let (:facts) do
        facts
      end
      it { should compile }
      it { should contain_anchor('bugzilla::begin') }
      it { should contain_anchor('bugzilla::end') }
      it { should contain_class('bugzilla') }
    end
  end
end
