namespace :redis do
  %w( start stop restart force-reload ).each do |cmd|
    desc "Send redis #{cmd} signal"
    task cmd, :role => :db do
      sudo "/etc/init.d/redis-server #{cmd}"
    end
  end
end
