def get_wind_down_time
  target_time_string = capture("[ -f #{current_path}/WIND_DOWN ] && cat #{current_path}/WIND_DOWN || echo -n ")
  if target_time_string.empty?
    nil
  else
    Time.parse(target_time_string)
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  unless exists? :wind_down_time
    set :wind_down_time, 60*60 # 1.hour
  end

  namespace :cache do
    desc "Start winding down the current deployment."
    task :winddown do
      run "echo '#{Time.now + wind_down_time}' > #{current_path}/WIND_DOWN"
      deploy.restart
    end

    desc "Cancel an in progress wind down."
    task :cancel_winddown do
      run "rm -f #{current_path}/WIND_DOWN"
      deploy.restart
    end

    desc "Check that wind down has completed (or was never started)."
    task :check_ready_to_deploy do
      if target_time = get_wind_down_time
        if target_time > Time.now
          puts "Servers are still winding down the cache.\nThey will be done at #{target_time} #{((target_time.to_i - Time.now.to_i)/60.0).ceil} mins from now.\nContinue with deploy?"
          raise "Servers still winding down." if STDIN.gets !~ /^y/i
        else
          puts "Wind Down completed at #{target_time}"
        end
      else
        puts "No wind down in progress."
      end
    end

    desc "Get info about the current state of the wind down."
    task :info do
      if target_time = get_wind_down_time
        if target_time > Time.now
          puts "Servers are winding down the cache.\nThey will be done at #{target_time} #{((target_time.to_i - Time.now.to_i)/60.0).ceil} mins from now."
        else
          puts "Wind Down completed at #{target_time}"
        end
      else
        puts "No wind down in progress."
      end
    end
  end

  before "deploy:update_code", "cache:check_ready_to_deploy"
end
