#
# Cookbook Name:: app
# Recipe:: default
# Author:: Tim Goh <tim.goh@citrusbyte.com>
#
# Copyright 2008-2009, Citrusbyte
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# see /nginx/recipes/default, paths are configured at compile-time
%w( /var/lib/nginx /var/lib/nginx/body /var/lib/nginx/proxy /var/lib/nginx/fastcgi ).each do |path|
  directory path do
    owner "www-data"
    group "root"
    mode "0700"
    action :create
  end
end

template "#{node[:nginx][:dir]}/sites-available/#{node[:app][:uri]}.conf" do
  source 'application.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

# enable the application's configuration
link "#{node[:nginx][:dir]}/sites-enabled/#{node[:app][:uri]}.conf" do
  to "#{node[:nginx][:dir]}/sites-available/#{node[:app][:uri]}.conf"
end

# install password file
if node[:app][:basic_auth] && node[:app][:basic_auth][:username] && node[:app][:basic_auth][:password]  
  htpasswd = "/srv/#{node[:app][:application]}/shared/config/htpasswd"
  
  file htpasswd do    
    owner "www-data"
    group "root"
    mode 0600
  end
  
  ruby_block "generate_htpasswd" do
    block do
      require "webrick/httpauth/htpasswd"
      
      ht = WEBrick::HTTPAuth::Htpasswd.new(htpasswd)
      ht.set_passwd("", node[:app][:basic_auth][:username], node[:app][:basic_auth][:password])
      ht.flush
    end
  end
end

logrotate "nginx_logs" do
  files node[:nginx][:log_dir] + "/*.log"
  frequency "daily"
  rotate_count 14
  compress true
  restart_command "/etc/init.d/nginx reload > /dev/null"
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :reload ]
end
