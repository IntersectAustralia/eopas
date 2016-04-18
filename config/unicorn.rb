current_path = '/home/deploy/eopas/current'
shared_path = '/home/deploy/eopas/shared'

# Set unicorn options
worker_processes 2
preload_app true
timeout 180
listen "#{shared_path}/sockets/unicorn.sock"

# Fill path to your app
working_directory current_path

# Should be 'production' by default, otherwise use other env 
rails_env = ENV['RAILS_ENV'] || 'production'

# Log everything
stderr_path "#{shared_path}/log/error.log"
stdout_path "#{shared_path}/log/out.log"

# Set master PID location
pid "#{shared_path}/pids/unicorn.pid"

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
