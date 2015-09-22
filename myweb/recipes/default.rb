# nginx
filename = 'nginx-release-centos-6-0.el6.ngx.noarch.rpm'
remote_uri = 'http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm'

remote_file "/tmp/#{filename}" do
  source "#{remote_uri}"
end

package 'nginx-repo' do
  action :install
  provider Chef::Provider::Package::Rpm
  source "/tmp/#{filename}"
end

case node[:platform]
when 'amazon'
  package 'nginx' do
    options '--disablerepo=amzn-main'
  end
when 'centos', 'redhat'
  package 'nginx'
end

service 'nginx' do
  action [:enable, :start]
end

#epel-release
filename = 'epel-release-6-8.noarch.rpm'
remote_uri = 'http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm'

remote_file "/tmp/#{filename}" do
  source "#{remote_uri}"
end

package 'epel-release' do
  action :install
  provider Chef::Provider::Package::Rpm
  source "/tmp/#{filename}"
  not_if "rpm -qa |grep epel-release"
end

# scl-util
filename = 'scl-utils-20120927-11.el6.centos.alt.x86_64.rpm'
remote_uri = 'http://mirror.centos.org/centos/6/SCL/x86_64/scl-utils/scl-utils-20120927-11.el6.centos.alt.x86_64.rpm'

remote_file "/tmp/#{filename}" do
  source "#{remote_uri}"
end

package 'scl-utils' do
  action :install
  provider Chef::Provider::Package::Rpm
  source "/tmp/#{filename}"
end

# remi for PHP5.6
filename = 'remi-release-6.rpm'
remote_uri = 'http://rpms.famillecollet.com/enterprise/remi-release-6.rpm'

remote_file "/tmp/#{filename}" do
  source "#{remote_uri}"
end

package 'remi' do
  action :install
  provider Chef::Provider::Package::Rpm
  source "/tmp/#{filename}"
end

%w{php56 php56-php-fpm php56-php-mbstring php56-php-mysqlnd php56-php-gd}.each do |pkg|
  yum_package pkg do
    options '--enablerepo=remi'
  end
end

service 'php56-php-fpm' do
  action [:enable, :start]
end

# set config
directory '/srv/www' do
  owner 'root'
  group 'root'
  mode '0755'
end

execute 'action' do
  command "sed -i 's/apache/nginx/g' /opt/remi/php56/root/etc/php-fpm.d/www.conf"
  notifies :restart, "service[php56-php-fpm]"
end

cookbook_file '/etc/nginx/conf.d/default.conf' do
  source 'default.conf'
  notifies :restart, "service[nginx]"
end

cookbook_file '/srv/www/phpinfo.php' do
  source 'phpinfo.php'
  notifies :restart, "service[nginx]"
end
