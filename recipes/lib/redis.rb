namespace :redis do
  desc "Symlink the Redis database directory and config"
  task :symlink, :roles => :app do
    run "ln -nfs #{shared_path}/config/redis/#{fetch(:rails_env, :production)}.conf #{release_path}/config/redis/#{fetch(:rails_env, :production)}.conf"
  end
  
  desc "Start the redis server"
  task :start, :roles => :app do
    run "cd #{current_path} && rake redis:start RAILS_ENV=#{fetch(:rails_env, :production)}"
  end

  desc "Stop the redis server"
  task :stop, :roles => :app do
    run "killall redis-server"
  end
end
