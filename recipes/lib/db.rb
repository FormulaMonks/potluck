namespace :db do
  desc "Dump the remote PostgreSQL database specified in Rails-style database.yml to a file"
  task :dump, :roles => :app do
    config = ""
    run "cat #{current_path}/config/database.yml" do |channel, stream, data|
      config << data
    end
    config = YAML.load(config)[fetch(:rails_env, :production)]
    run "cd ~ && env PGPASSWORD=#{config["password"]} pg_dump #{config["database"]} > #{config["database"]}.pgdump"
    puts "Database #{config["database"]} dumped to ~/#{config["database"]}.pgdump"
  end
end
