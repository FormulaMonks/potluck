namespace :srv do
  desc "Give uptime status"
  task :uptime, :roles => :app do
    run "uptime" do |channel, stream, data|
      puts "#{channel[:server]}: #{data}"
      break if stream == :err
    end
  end

  desc "Give free memory status"
  task :free, :roles => :app do
    free = {}
    roles[:app].each{ |role| free[role.port] = '' }
    run "free -m" do |channel, stream, data|
      free[channel[:server].port] << data
      break if stream == :err
    end
    free.each do |port, data|
      puts "#{port}:\n#{data}"
    end
  end
end
