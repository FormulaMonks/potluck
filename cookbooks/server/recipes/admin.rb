#
# Cookbook Name:: admin
# Recipe:: default
#
# Copyright 2009, Citrusbyte
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

group "sysadmin" do
  action :create
end

user "#{node[:app][:user]}" do
  action :create
  comment "main administrative user"
  gid "sysadmin"
  home "/home/#{node[:app][:user]}"
  shell "/bin/bash"
end

template "/etc/sudoers" do
  owner "root"
  group "root"
  source "sudoers.erb"
  mode 0440
end

directory "/home/#{node[:app][:user]}" do
  owner "#{node[:app][:user]}"
  group "sysadmin"
  mode 0750
  action :create
end

directory "/home/#{node[:app][:user]}/.ssh" do
  owner "#{node[:app][:user]}"
  group "sysadmin"
  mode 0700
  action :create
end

directory "/home/#{node[:app][:user]}/gem_builds" do
  owner "#{node[:app][:user]}"
  group "sysadmin"
  mode 0750
  action :create
end

execute "ssh-keygen" do
  user "#{node[:app][:user]}"
  command "ssh-keygen -q -f /home/#{node[:app][:user]}/.ssh/id_rsa -P \"\""
  creates "/home/#{node[:app][:user]}/.ssh/id_rsa"
  action :run
end

tools = case node[:platform]
  when "debian", "ubuntu"
    %w{less screen htop multitail}
  else
    #TODO
  end

tools.each do |pkg|
  package pkg
end

template "/home/#{node[:app][:user]}/.screenrc" do
  owner "#{node[:app][:user]}"
  source 'screenrc.erb'
end
