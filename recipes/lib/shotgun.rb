namespace :shotgun do
  desc "Start your application with shotgun"
  task :start, :role => :app do
    run %Q{cd #{current_path} && shotgun -p 9292 -o 0.0.0.0}
  end
  
  desc "Stop any applications running with shotgun"
  task :stop, :role => :app do
    pids = []
    
    run "ps aux | grep 'bin\/shotgun' | grep -v grep | awk '{print $2}'" do |channel, stream, data|
      pids = data.split("\n")
    end
    
    pids.each do |pid|
      run "kill -9 #{pid}"
    end
  end
end
