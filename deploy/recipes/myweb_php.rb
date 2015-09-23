#
# Cookbook Name:: deploy
# Recipe:: php
#

include_recipe 'deploy'

dbname = node[:deploy][:wordpress][:database][:database]
dbuser = node[:deploy][:wordpress][:database][:username]
dbpass = node[:deploy][:wordpress][:database][:password]
dbhost = node[:deploy][:wordpress][:database][:host]

mysql_command = "/usr/bin/mysql -u #{dbuser} -p#{dbpass} -h #{dbhost}"

#include_recipe "mod_php5_apache2"
#include_recipe "mod_php5_apache2::php"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  execute "create mysql databases" do
    command  "#{mysql_command} -e 'CREATE DATABASE #{dbname}'"
    not_if do
     system("#{mysql_command} -e 'SHOW DATABASES' | egrep -e '^#{dbname}$'") 
    end
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  service 'nginx' do
    action :restart
  end
end
