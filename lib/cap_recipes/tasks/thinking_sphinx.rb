Capistrano::Configuration.instance(true).load do
  namespace :thinking_sphinx do

    # ===============================================================
    # PROCESS MANAGEMENT
    # ===============================================================  
    
    desc "Starts the thinking sphinx searchd server"
    task :start, :roles => :app do
      puts "Starting thinking sphinx searchd server"
      rake = fetch(:rake, "rake")
      rails_env = fetch(:rails_env, "production")

      run "cd #{current_path}; #{rake} RAILS_ENV=#{rails_env} thinking_sphinx:configure; #{rake} RAILS_ENV=#{rails_env} ts:start"
    end
    
    desc "Stops the thinking sphinx searchd server"
    task :stop, :roles => :app do
      puts "Stopping thinking sphinx searchd server"
      rake = fetch(:rake, "rake")
      rails_env = fetch(:rails_env, "production")

      run "cd #{current_path}; #{rake} RAILS_ENV=#{rails_env} thinking_sphinx:configure; #{rake} RAILS_ENV=#{rails_env} ts:stop"
    end
    
    desc "Restarts the thinking sphinx searchd server"
    task :restart, :roles => :app do
      thinking_sphinx.stop
      thinking_sphinx.index
      thinking_sphinx.start
    end


    # ===============================================================
    # FILE MANAGEMENT
    # ===============================================================  
    
    desc "Copies the shared/config/sphinx yaml to release/config/"
    task :copy_config, :roles => :app do
      run "ln -s #{shared_path}/config/sphinx.yml #{release_path}/config/sphinx.yml"
    end
    
    desc "Displays the thinking sphinx log from the server"
    task :tail, :roles => :app do
      stream "tail -f #{shared_path}/log/searchd.log"
    end

    desc "Runs Thinking Sphinx indexer"
    task :index, :roles => :app do
      rake = fetch(:rake, "rake")
      rails_env = fetch(:rails_env, "production")
      puts "Updating search index"

      run "cd #{current_path}; #{rake} RAILS_ENV=#{rails_env} ts:index"
    end
  end
  
  # ===============================================================
  # TASK CALLBACKS
  # ===============================================================  
  
  after "deploy:update_code", "thinking_sphinx:copy_config" # copy thinking_sphinx.yml on update code
  after "deploy:restart"    , "thinking_sphinx:restart"     # restart thinking_sphinx on app restart
end