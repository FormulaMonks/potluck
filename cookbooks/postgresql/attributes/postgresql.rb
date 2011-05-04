#
# Cookbook Name:: postgresql
# Attributes:: postgresql
#
# Copyright 2008, OpsCode, Inc.
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

postgresql Mash.new unless attribute?("postgresql")

# simple fix for the fact that ubuntu 10.04 changed to 8.4
postgresql[:version] = (platform == "ubuntu" && platform_version == "10.04" ? "8.4" : "8.3")

case platform
when "redhat","centos","fedora","suse"
  postgresql[:dir]     = "/var/lib/pgsql/data"
when "debian","ubuntu"
  postgresql[:dir]     = "/etc/postgresql/#{postgresql[:version]}/main"
else
  postgresql[:dir]     = "/etc/postgresql/#{postgresql[:version]}/main"
end
