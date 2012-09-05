module Services
  class ErrorProcessing

    attr_reader :log, :app, :error

    def initialize(log)
      @log = log
      @app = App.find(log.api_key)
      @error = app.errors.find_by(crc: log.crc)
    end

    def run
      if @error
        create_error_info
      else
        create_new_error
      end
      firehose = Firehose::Producer.new(APP_CONFIG[:firehose_url])
      firehose.publish({
        title: error.title,
        no: error.no
      }.to_json).to("/errors/#{error._id}")
    end

  private

    def create_new_error
      @error = @app.errors.create({
        crc:    log.crc,
        hash_id:   log.hash_id,
        title:  log.exception_message,
        backtrace:  log.backtrace,
        no: 1
      })
      create_error_info
    end

    def create_error_info
      @error_info = @error.error_info.create({
        env:              log.environment,
        occured_at:       log.occured_at,
        exception_class:  log.exception_class
      })
      @error.update_attribute(:no, @error.error_info.size)
    end

  end
end
