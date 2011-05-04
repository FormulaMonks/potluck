#
# Cookbook Name:: nginx
# Recipe:: default
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008-2009, Opscode, Inc.
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
#

package "libssl-dev"

script "nginx_from_source" do
  not_if "test -x /usr/sbin/nginx"
  interpreter "bash"
  user "root"
  cwd "/tmp"
  # lenny default settings
  # http://wiki.nginx.org/NginxInstallOptions
  code <<-BASH
    apt-get build-dep nginx -y
    wget http://sysoev.ru/nginx/nginx-0.8.54.tar.gz
    tar zxf nginx-0.8.54.tar.gz
    cd nginx-0.8.54
    ./configure \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=#{node[:nginx][:log_dir]}/error.log \
      --pid-path=#{node[:nginx][:pid_file]} \
      --lock-path=/var/lock/nginx.lock \
      --http-log-path=#{node[:nginx][:log_dir]}/access.log \
      --with-http_dav_module \
      --http-client-body-temp-path=/var/lib/nginx/body \
      --with-http_ssl_module \
      --http-proxy-temp-path=/var/lib/nginx/proxy \
      --with-http_stub_status_module \
      --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
      --with-debug \
      --with-http_flv_module 
    make
    make install
    ln -s /usr/local/nginx/sbin/nginx #{node[:nginx][:binary]}
  BASH
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

['sites-available', 'sites-enabled'].each do |d|
  directory "#{node[:nginx][:dir]}/#{d}" do
    action :create
    owner 'www-data'
    group 'www-data'
    mode 0644
  end
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

template "/etc/init.d/nginx" do
  source "nginx.init.d.erb"
  owner "root"
  group "root"
  mode 0755
end

execute "add_nginx_to_services" do
  user "root"
  command "/usr/sbin/update-rc.d -f nginx defaults"
  not_if "test -f /etc/rc5.d/nginx"
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

include_recipe "nginx::application"