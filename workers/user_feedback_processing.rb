class UserFeedbackProcessor
  @queue = "UserFeedback"

  def self.perform(log_id)
    log = UserFeedbackLog.find(log_id)
    Services::UserFeedbackProcessing.new(log).run
    puts 'ok'
  end
end
