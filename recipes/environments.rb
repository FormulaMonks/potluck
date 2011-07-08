task :production do
  set :application, "my_app"
  set :vhost,       "my_app.com"
  
  set :scm,         "git"
  set :repository,  "git:my_app.git"
  set :branch,      "master"
  set :rails_env,   "production"
  set :rack_env,    "production"
  set :deploy_to,   "/srv/#{application}"
  set :user,        "admin" # this should match the username in production.dna.json
  
  role :app, "my_app"
  role :db,  "my_app", :primary => true
  role :web, "my_app"
end

task :staging do
  set :application, "my_app"
  set :vhost,       "staging.my_app.com"
  
  set :scm,         "git"
  set :repository,  "git:my_app.git"
  set :branch,      "master"
  set :rails_env,   "production"
  set :rack_env,    "production"
  set :deploy_to,   "/srv/#{application}"
  set :user,        "admin" # this should match the username in staging.dna.json
  
  role :app, "my_app-staging"
  role :db,  "my_app-staging", :primary => true
  role :web, "my_app-staging"
end

# TODO: read application name and IP from Vagrantfile
task :development do
  set :application, "my_app" # this should match the name of your app in your Vagrantfile
  set :user,        "vagrant"
  set :deploy_to,   "/srv/#{application}"

  role :app, "33.33.33.10" # this should match the IP given to config.vm.network(...) in your Vagrantfile
end
