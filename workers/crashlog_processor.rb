class CrashlogProcessor
  @queue = "CrashLogs"

  def self.perform(log_id)
    log = Crashlog.find(log_id)
    Services::ErrorProcessing.new(log).run
    puts 'ok'
  end
end
