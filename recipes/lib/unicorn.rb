before "unicorn:restart", "unicorn:ensure_setup"
before "unicorn:start",   "unicorn:ensure_setup"

namespace :unicorn do
  desc "Symlink unicorn config"
  task :ensure_setup, :role => :app do
    run "ln -nfs #{shared_path}/config/unicorn.rb #{current_path}/config/unicorn.rb"
  end
  
  %w( start stop restart upgrade rotate force-stop ).each do |cmd|
    desc "Send unicorn #{cmd} signal"
    task cmd, :role => :app do
      sudo "/etc/init.d/unicorn #{cmd}"
    end
  end
  
  namespace :tail do
    desc "Tail unicorn's stdout log for this application/environment"
    task :stdout, :roles => :app do
      do_tail "/var/log/unicorn/#{application}.stdout.log"
    end

    desc "Tail unicorn's stderr log for this application/environment"
    task :stderr, :roles => :app do
      do_tail "/var/log/unicorn/#{application}.stderr.log"
    end
  end
end
