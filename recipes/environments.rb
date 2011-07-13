task :production do
  set :application, "my_app"              # Name of your application, used to figure out your deploy_to path, as well as in various other recipes
  set :vhost,       "my_app.com"          # Primary vhost of your application, should match the "app": { "uri": ... } in your <environment>.dna.json
  
  set :scm,         "git"                 # SCM type you will be deploying from, changing this will result in various other changes
  set :repository,  "git:my_app.git"      # URL to the git repository you're deploying from, note that we typically use an alias in ~/.ssh/config rather than a full URL here
  set :branch,      "master"              # Branch to deploy from, this typically matches the environment name for launched projects
  set :rails_env,   "production"          # Environment Rails applications will be run in
  set :rack_env,    "production"          # Environment Rack applications will be run in
  set :deploy_to,   "/srv/#{application}" # Root path to deploy the application to, note that capistrano uses the current, shared & releases paths below this
  set :user,        "admin"               # Username of your deploy users, should match "app": { "user": ... } in your <environment>.dna.json
  
  role :app, "my_app"                     # IP, hostname or SSH-alias of your application server
  role :db,  "my_app", :primary => true   # IP, hostname or SSH-alias of your db server (typically same as your app server)
  role :web, "my_app"                     # IP, hostname or SSH-alias of your web server (typically same as your app server)
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

task :development do
  # The following attempts (albeit in a very ugly fashion) to read relevant
  # variables from your Vagrantfile, so you don't have to alter this file for
  # your development environment. If things have changed signifantly, you can
  # remove all this and manually manage your development environment config to
  # match your Vagrantfile settings.
  # 
  # For manual configuration:
  # 
  # set :user,        "vagrant"             # The name of the ssh user `vagrant ssh` uses
  # set :application, "my_app"              # The name of the @application in your Vagrantfile (not required if deploy_to is set properly below)
  # set :deploy_to,   "/srv/#{application}" # The path to your share_folder, w/o the `current` part
  # 
  # role :app, "33.33.33.10"                # The IP or ssh alias of your Vagrant VM
  
  # Default location for Vagrantfile is in the project root, which is expected
  # to be 2 folders up from here, otherwise define on ENV["VAGRANTFILE"]
  VAGRANTFILE = ENV["VAGRANTFILE"] || File.join(File.expand_path(File.join(File.dirname(__FILE__), "..", "..")), "Vagrantfile")
  
  require "vagrant"
  require "ostruct"
  
  vagrant = Vagrant::Config.new
  vagrant.load_order = [:vagrantfile]
  vagrant.set(:vagrantfile, VAGRANTFILE)
  config = vagrant.load(self)
  vm = OpenStruct.new
  config.vm.customize[0].call(vm)
  
  set :user, "vagrant"
  set :application, vm.name
  set :deploy_to, "/srv/#{application}"  
  role :app, config.vm.network_options[1][:ip]  
end
