namespace :nginx do
  %w( start stop restart upgrade rotate force-stop ).each do |cmd|
    desc "Send nginx #{cmd} signal"
    task cmd, :role => :app do
      sudo "/etc/init.d/nginx #{cmd}"
    end
  end

  namespace :tail do
    desc "Tail nginx access log for this application/environment"
    task :access, :roles => :app do
      do_tail "/var/log/nginx/#{vhost}.log"
    end

    desc "Tail nginx error log for this application/environment"
    task :error, :roles => :app do
      do_tail "/var/log/nginx/#{vhost}-error.log"
    end
  end
end
