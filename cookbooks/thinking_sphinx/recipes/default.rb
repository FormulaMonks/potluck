require 'pp'
#
# Cookbook Name:: thinking_sphinx
# Recipe:: default
#

postgresql[:version] = (platform == "ubuntu" && platform_version == "10.04" ? "8.4" : "8.3")

# sphinx w/ postgres support relies on existence of pg_config
package 'libpq-dev' do
  action :install
  not_if 'test -x /usr/bin/pg_config'
end

script "sphinx_from_source" do
  not_if "test -x /usr/local/bin/searchd"
  interpreter "bash"
  user "root"
  cwd "/tmp"
  # http://www.postneo.com/2009/02/06/sphinx-search-with-postgresql
  # adapted for sphinx 0.9.9
  code <<-BASH
    wget http://www.sphinxsearch.com/downloads/sphinx-0.9.9.tar.gz
    tar xzvf sphinx-0.9.9.tar.gz
    cd sphinx-0.9.9
    ./configure \
      --without-mysql \
      --with-pgsql \
      --with-pgsql-includes=/usr/include/postgresql/ \
      --with-pgsql-lib=/usr/lib/postgresql/#{postgresql[:version]}/lib/
    make
    make install
  BASH
end

directory "/var/run/sphinx" do
  owner node[:app][:user]
  group 'sysadmin'
  mode 0755
end

directory "/var/log/sphinx" do
  recursive true
  owner node[:app][:user]
  group 'sysadmin'
  mode 0755
end

directory "/srv/#{node[:app][:application]}/shared/config/" do
  owner "#{node[:app][:user]}"
  group "www-data"
  mode 0755
  recursive true
end

template "/srv/#{node[:app][:application]}/shared/config/sphinx.yml" do
  owner node[:app][:user]
  group 'sysadmin'
  mode 0644
  source "sphinx.yml.erb"
end

# postgres needs this language installed so thinking_sphinx can install crc32
# FIXME: this is a *total* hack :p
execute "add plpgsql" do
  user "postgres"
  command "if createlang -l #{node[:app][:db][:name]} | grep plpgsql; then echo 'foo' > /dev/null; else createlang plpgsql #{node[:app][:db][:name]}; fi;"
end

logrotate "sphinx_logs" do
  files "/var/log/sphinx/*.log"
  frequency "daily"
  rotate_count 14
  compress true
  restart_command "killall -SIGUSR1 searchd"
end
