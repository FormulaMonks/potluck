#
# Cookbook Name:: app
# Recipe:: dependencies
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


# build + ruby
%w( build-essential ruby1.8-dev git-core libfcgi-dev libfcgi-ruby1.8 irb ).each { |pack| package pack }

execute "update rubygems" do
  user "root"
  command "gem update --system"
  # TODO: only update if lower than version 1.3.6 to ensure gemcutter source
  action :run
end

# newest rake is needed for things like rails migrations, so don't install
# linux package version
gem_package "rake"
