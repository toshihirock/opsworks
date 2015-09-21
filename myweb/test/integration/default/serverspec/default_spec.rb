require 'spec_helper'

describe 'myweb::default' do
  describe package('php56') do
    it { should be_installed }
  end
  %w{nginx php56-php-fpm}.each do |pkg|
    describe service(pkg) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe port('80') do
    it { should be_listening.with('tcp') }
  end
end
