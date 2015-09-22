require 'spec_helper'

describe 'myweb::default' do
  %w{php56 php56-php-mbstring php56-php-mysqlnd php56-php-gd}.each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
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
