namespace :sphinx do
  desc "Symlink the Sphinx database directory"
  task :symlink, :roles => :app do
    run "mkdir -p #{release_path}/db/sphinx"
    run "ln -nfs #{shared_path}/db/sphinx/#{fetch(:rails_env, :production)} #{release_path}/db/sphinx/#{fetch(:rails_env, :production)}"
    run "ln -nfs #{shared_path}/config/sphinx.yml #{release_path}/config/sphinx.yml"
  end
end
