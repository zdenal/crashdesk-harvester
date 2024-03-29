require 'resque/tasks'

namespace :resque do
  task :setup

  desc "Restart running workers"
  task :restart_workers do
    Rake::Task['resque:stop_workers'].invoke
    Rake::Task['resque:start_workers'].invoke
  end

  desc "Quit running workers"
  task :stop_workers do
    stop_workers
  end

  desc "Start workers"
  task :start_workers do
    # Update this for get params from capistrano
    run_worker("CrashLogs", 5)
  end

  def store_pids(pids, mode)
    pids_to_store = pids
    pids_to_store += read_pids if mode == :append

    # Make sure the pid file is writable.
    pid_directory = File.expand_path('tmp/pids', Sinatra::Application.root)
    FileUtils.mkdir_p pid_directory
    File.open(File.join(pid_directory, 'resque.pid'), 'a') do |f|
      f <<  pids_to_store.join(',')
    end
  end

  def read_pids
    pid_file_path = File.expand_path('tmp/pids/resque.pid', Sinatra::Application.root)
    return []  if ! File.exists?(pid_file_path)

    File.open(pid_file_path, 'r') do |f| 
      f.read 
    end.split(',').collect {|p| p.to_i }
  end

  def stop_workers
    pids = read_pids

    if pids.empty?
      puts "No workers to kill"
    else
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "$ #{syscmd}"
      `#{syscmd}`
      store_pids([], :write)
    end
  end

  # Start a worker with proper env vars and output redirection
  def run_worker(queue, count = 1)
    puts "Starting #{count} worker(s) with QUEUE: #{queue}"

    ##  make sure log/resque_err, log/resque_stdout are writable.
    ops = {:pgroup => true, :err => [(Sinatra::Application.root + "/log/resque_err").to_s, "a"], 
                            :out => [(Sinatra::Application.root + "/log/resque_stdout").to_s, "a"]}
    env_vars = {"QUEUE" => queue.to_s, 'RAILS_ENV' => Sinatra::Application.environment.to_s}

    pids = []
    count.times do
      ## Using Kernel.spawn and Process.detach because regular system() call would
      ## cause the processes to quit when capistrano finishes
      pid = spawn(env_vars, "rake resque:work", ops)
      Process.detach(pid)
      pids << pid
    end

    store_pids(pids, :append)
  end
end
