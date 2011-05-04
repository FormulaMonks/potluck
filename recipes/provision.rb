require "json"

on :before, :only => %w( provision:all provision:bootstrap provision:reboot provision:chef:all provision:chef:configs provision:chef:cookbooks provision:chef:update ) do
  unless fetch(:user) == "root"
    set :user, "root"
    puts <<-WARNING
===============================================================================

    WARNING: Running as root for provisioning!

===============================================================================
WARNING
  end
end

namespace :provision do
  set :deploy_root, File.expand_path(File.dirname(__FILE__) + '/..')
  
  desc "Prepare slice for Chef"
  task :bootstrap do
    # upgrade slice
    run "apt-get update -y"
    run "apt-get upgrade -y"
    
    run "apt-get install build-essential ruby ruby-dev libopenssl-ruby -y"
    
    # rubygems
    run <<-CMD
      cd /tmp &&
      wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.6.tgz &&
      tar zxf rubygems-1.3.6.tgz
    CMD
    run "cd /tmp/rubygems-1.3.6 && ruby setup.rb"
    run "ln -sfv /usr/bin/gem1.8 /usr/bin/gem"

    # chef
    run "gem install chef --no-rdoc --no-ri"
    run "mkdir -p /etc/chef"

    # generate locale
    run "locale-gen en_US.UTF-8"
    run "/usr/sbin/update-locale LANG=en_US.UTF-8"

    # set hostname (required by chef to set domain attribute)
    hostname = Capistrano::CLI.ui.ask("Hostname: ")
    fqdn     = Capistrano::CLI.ui.ask("FQDN: ")
    run "echo '#{hostname}' > /etc/hostname"
    run "echo '127.0.0.1 #{fqdn} #{hostname} localhost localhost.localdomain' > /etc/hosts"  
  end
  
  desc "Entirely set up the server: Prepare the server for chef, configure and run chef update, then set the hostname and reboot"
  task :all do
    bootstrap
    reboot
    puts <<-MSG
===============================================================================

  Your server is rebooting to populate the FQDN and Hostname for Chef, script
  will continue in 60 seconds...
  
  If it fails in 60 seconds, try:
  
    $ cap <environment> provision:chef:all

===============================================================================
    MSG
    sleep 60
    chef.all
  end
  
  desc "Shutdown and reboot NOW! :)"
  task :reboot do
    run "shutdown -r now"
  end
    
  namespace :chef do    
    desc "Updates chef-solo and dna configs on server"
    task :configs do
      raise "No #{configuration}.dna.json in #{deploy_root}/files" unless File.exists?("#{deploy_root}/files/#{configuration}.dna.json")
      raise "Unable to parse #{configuration}.dna.json, make sure it is valid JSON" unless JSON.parse(File.read("#{deploy_root}/files/#{configuration}.dna.json"))
      
      upload "#{deploy_root}/files/chef-solo.rb", "/etc/chef/chef-solo.rb"
      upload "#{deploy_root}/files/#{configuration}.dna.json", "/etc/chef/dna.json"
    end

    desc "Packages and uploads cookbooks"
    task :cookbooks do
      `tar zcf #{deploy_root}/files/cookbooks.tar.gz -C #{deploy_root}/ cookbooks` 
      upload "#{deploy_root}/files/cookbooks.tar.gz", "/etc/chef/cookbooks.tar.gz"
    end

    desc "Updates server with your cookbooks and DNA"
    task :update do
      run "chef-solo -l debug -c /etc/chef/chef-solo.rb -j /etc/chef/dna.json -r /etc/chef/cookbooks.tar.gz"
    end  

    desc "Upload configs and cookbooks then update"
    task :all do
      configs
      cookbooks
      update
    end

    desc "Tails chef-solo log"
    task :tail do
      do_tail "/var/log/chef-solo.log"
    end
  end
end
