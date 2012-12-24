module Services
  class UserFeedbackProcessing

    attr_reader :log, :app, :error, :user_feedback

    def initialize(user_feedback_log)
      @log = user_feedback_log
      @app = App.find(log.app_key)
      @error = app.error_info.find_by(hash_id: @log.hash_id)
    end

    def run
      if @error
        create_new_feedback
      else
        Resque.enqueue(UserFeedbackProcessor, @log.id) # run it later
      end
    end

  private

    def create_new_feedback
      @user_feedback = @error.user_feedback.create({
        email:      @log.email,
        message:    @log.message,
        occured_at: @log.occured_at
      })
    end

  end
end
