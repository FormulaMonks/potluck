after "deploy:symlink", "deploy:symlink_dirs"
after "deploy:symlink", "deploy:symlink_configs"
after "deploy:symlink", "deploy:compile_sass"

namespace :deploy do
  # turn off unnecessary tasks
  overrides = [ :setup, :check, :cold, :start, :restart, :stop ]
  overrides.each {|t| task t do; end }
  
  task(:start)   { unicorn.start }
  task(:stop)    { unicorn.stop }
  task(:restart) { unicorn.restart }

  task :versions, :role => :app do
    run "sh -c 'cd #{current_path} && cat REVISION'"
  end

  desc "Show the differences between settings.yml and settings.yml.sample"
  task :check_settings, :roles => :app do
    run "cd #{current_path} && rake settings:check RAILS_ENV=#{fetch :rails_env, :production}"
  end

  task :symlink_configs, :role => :app do
    %w( settings.yml database.yml ).each do |filename|
      run "ln -nfs #{shared_path}/config/#{filename} #{current_path}/config/#{filename}"
    end
  end

  desc "Symlink persisted directories"
  task :symlink_dirs, :roles => :app, :except => { :no_symlink => true } do
    %w( ).each do |directory|
      run "mkdir -p #{shared_path}/#{directory}"
      run "ln -nfs #{shared_path}/#{directory} #{current_path}/#{directory}"
    end
  end

  desc "Update CSS files and replace relative urls with absolute ones"
  task :compile_sass, :roles => :app do
    haml_dir = 'haml'
    run "ls #{current_path}/vendor/gems | grep haml" do |channel, stream, data|
      haml_dir = data
    end
    run <<-BASH
      for file in #{current_path}/public/stylesheets/sass/*.sass; do
        cd #{current_path}/public/stylesheets/ && #{current_path}/vendor/gems/#{haml_dir}/bin/sass $file #{current_path}/public/stylesheets/`basename ${file%.sass}`.css ; done
    BASH
  end
  
  desc "Print out the public deploy key for the administrative user"
  task :key, :roles => :app do
    run("cat ~/.ssh/id_rsa.pub") do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{data}"
      puts
      break if stream == :err
    end
  end
  
  desc "Put your public key into authorized_keys for the deploy user"
  task :auth, :roles => :app do
    pub_key = File.read(File.expand_path('~/.ssh/id_rsa.pub')) rescue raise('Couldn\'t read ~/.ssh/id_rsa.pub, do you have a public key?')
    run "echo \"#{pub_key}\" >> ~/.ssh/authorized_keys"
  end
  
  desc "Display the maintenance.html page while deploying with migrations. Then it restarts and enables the site again."
  task :long do
    transaction do
      update_code
      web.disable
      symlink
      migrate
    end

    restart
    web.enable
  end
end

# from engineyard-eycap 0.4.12
# http://github.com/engineyard/eycap
# 
# == LICENSE:
# 
# Copyright (c) 2008-2011 Engine Yard
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
namespace :web do
  desc <<-DESC
    Present a maintenance page to visitors. Disables your application's web \
    interface by writing a "maintenance.html" file to each web server. The \
    servers must be configured to detect the presence of this file, and if \
    it is present, always display it instead of performing the request.

    By default, the maintenance page will just say the site is down for \
    "maintenance", and will be back "shortly", but you can customize the \
    page by specifying the REASON and UNTIL environment variables:

      $ cap deploy:web:disable \\
            REASON="hardware upgrade" \\
            UNTIL="12pm Central Time"

    Further customization copy your html file to shared_path+'/system/maintenance.html.custom'.
    If this file exists it will be used instead of the default capistrano ugly page
  DESC
  task :disable, :roles => :web, :except => { :no_release => true } do
    maint_file = "#{shared_path}/system/maintenance.html"
    require 'erb'
    on_rollback { run "rm #{shared_path}/system/maintenance.html" }

    reason = ENV['REASON']
    deadline = ENV['UNTIL']

    template = File.read(File.join(File.dirname(__FILE__), "templates", "maintenance.rhtml"))
    result = ERB.new(template).result(binding)

    put result, "#{shared_path}/system/maintenance.html.tmp", :mode => 0644
    run "if [ -f #{shared_path}/system/maintenance.html.custom ]; then cp #{shared_path}/system/maintenance.html.custom #{maint_file}; else cp #{shared_path}/system/maintenance.html.tmp #{maint_file}; fi"
  end
end
