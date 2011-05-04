namespace :app do
  desc "Tail the Rails log for this environment"
  task :tail, :roles => :app do
    do_tail "#{shared_path}/log/#{fetch(:rails_env, :production)}.log"
  end
end
