execute "install unicorn" do
  user "root"
  command %Q(gem install unicorn --no-ri --no-rdoc)
  not_if "gem list | grep unicorn"
end

directory "/var/log/unicorn" do
  action :create
  owner "root"
  group "root"
  mode 0755
end

logrotate "unicorn_logs" do
  files "/var/log/unicorn/*.log"
  frequency "daily"
  rotate_count 14
  compress true
  restart_command "/etc/init.d/unicorn reload > /dev/null"
end

directory "/var/unicorn" do
  action :create
  owner "#{node[:app][:user]}"
  group "www-data"
  mode 0755
end

# application configuration ===================================================
template "/srv/#{node[:app][:application]}/shared/config/unicorn.rb" do
  source 'unicorn.rb.erb'
  owner "#{node[:app][:user]}"
  group "www-data"
  mode 0644
end

template "/etc/init.d/unicorn" do
  source "unicorn.sh.erb"
  owner "root"
  group "root"
  mode 0755
end

service "unicorn" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end
