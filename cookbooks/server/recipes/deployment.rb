#
# Cookbook Name:: app
# Recipe:: deployment
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
#

# deployment ==================================================================
directory "/srv/#{node[:app][:application]}" do
  owner "#{node[:app][:user]}"
  group "www-data"
  mode 0755
  recursive true
end

cap_directories = %w( shared shared/log shared/config shared/system shared/pids releases )
cap_directories.each do |dir|
  directory "/srv/#{node[:app][:application]}/#{dir}" do
    owner "#{node[:app][:user]}"
    group "www-data"
    mode 0755
    recursive true
  end
end

template "/srv/#{node[:app][:application]}/shared/config/settings.yml" do
  source 'settings.yml.erb'
  owner "#{node[:app][:user]}"
  group "www-data"
  mode 0644
  not_if "test -e /srv/#{node[:app][:application]}/shared/config/settings.yml"
end
