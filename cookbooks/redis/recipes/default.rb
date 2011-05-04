#
# Author:: Benjamin Black (<b@b3k.us>)
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2009, Benjamin Black
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

script "redis_from_source" do
  not_if "test -x /usr/bin/redis-server"
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-BASH
    wget http://redis.googlecode.com/files/redis-2.2.5.tar.gz
    tar zxf redis-2.2.5.tar.gz
    cd redis-2.2.5
    make
    mv src/redis-server /usr/bin/redis-server-2.2.5
    mv src/redis-cli /usr/bin/redis-cli-2.2.5
    ln -s /usr/bin/redis-server-2.2.5 /usr/bin/redis-server
    ln -s /usr/bin/redis-cli-2.2.5 /usr/bin/redis-cli
  BASH
end

template "/etc/init.d/redis-server" do
  source "redis-server.erb"
  owner "root"
  group "root"
  mode 0755
end

group node[:redis][:group] do
  action :create
end

user node[:redis][:user] do
  action :create
  comment "redis user"
  gid node[:redis][:group]
  system true
  shell "/bin/false"
end

directory "/etc/redis" do
  owner "root"
  group "root"
  mode 0755
end

directory node[:redis][:dbdir] do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/var/log/redis.log" do
  owner "redis"
  group "redis"
end

directory @node[:redis][:dbdir] do
  owner "redis"
  group "redis"
  mode "0755"
  action :create
end

service "redis-server" do
  action [ :enable, :start ]
end

template "/etc/redis/redis.conf" do
  source "redis.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "redis-server")
end
