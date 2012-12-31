namespace :test do
  desc 'dump last Crashlog to yaml for tests'
  task :dump_crashlog do
    unless Crashlog.exists?
      puts 'No crashlog available'
      exit 0
    end
    path = Pathname.new('spec/cassettes/crashlog.yml')
    FileUtils.mkdir_p path.dirname.to_s
    File.open(path.to_s, 'w') do |file|
      file.puts YAML.dump(Crashlog.last.attributes)
    end
    puts 'OK'
  end
end
