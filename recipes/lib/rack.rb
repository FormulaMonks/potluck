namespace :rack do
  desc "Start your application using rackup"
  task :start, :role => :app do
    run %Q{cd #{current_path} && rackup -D}
  end
  
  desc "Ruthlessly kill anything running with rackup"
  task :stop, :role => :app do
    pids = []
    
    run "ps aux | grep 'bin\/rackup' | grep -v grep | awk '{print $2}'" do |channel, stream, data|
      pids = data.split("\n")
    end
    
    pids.each do |pid|
      run "kill -9 #{pid}"
    end
  end

  desc "Restart your application running with rackup"
  task :restart, :role => :app do
    stop
    start
  end
end
