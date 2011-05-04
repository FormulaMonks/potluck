namespace :webrick do
  task :start, :role => :app do
    run %Q{cd #{current_path} && ruby init.rb}
  end
  
  task :stop, :role => :app do
    sudo %Q{ps aux | grep '[0-9] ruby init.rb' | awk '{print $2}' | xargs kill -9}
  end
end
