# required for ruby bindings
package "libpq-dev"
gem_package "postgres"

execute "create_postgres_user" do
  user 'postgres'
  command %Q(psql -c 'SELECT u.usename FROM pg_catalog.pg_user u' | grep #{node[:app][:user]} || createuser --no-superuser --no-createdb --no-createrole -e #{node[:app][:user]})
  action :run
end

execute "set_postgres_user_password" do
  user 'postgres'
  command %Q(psql -c "alter user #{node[:app][:user]} encrypted password '#{node[:app][:db][:password]}';")
end

execute "create_production_db" do
  user 'postgres'
  command %Q(psql -c 'SELECT d.datname FROM pg_catalog.pg_database d' | grep #{node[:app][:db][:name]} || createdb #{node[:app][:db][:name]})
  action :run
end

# TODO: move to rails cookbook
template "/srv/#{node[:app][:application]}/shared/config/database.yml" do
  source 'database.yml.erb'
  owner "#{node[:app][:user]}"
  group "www-data"
  mode 0644
end
