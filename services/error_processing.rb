module Services
  class ErrorProcessing

    attr_reader :log, :app, :error

    def initialize(log)
      @log = log
      @app = App.find(log.app_key)
      @error = app.error_info.find_by(crc: log.crc)
    end

    def run
      if @error
        create_error_detail
      else
        create_new_error
      end
    end

  private

    def create_new_error
      @error = @app.error_info.create({
        crc:    log.crc,
        hash_id:   log.hash_id,
        title:  log.exception_message,
        backtrace:  log.backtrace,
        no: 1
      })
      create_error_detail
    end

    def create_error_detail
      @error_info = @error.error_details.create({
        env:              log.environment,
        occured_at:       log.occured_at,
        exception_class:  log.exception_class
      })
      @error.update_attribute(:no, @error.error_details.size)
    end

    def push_firehose_info
      firehose = Firehose::Producer.new(APP_CONFIG[:firehose_url])
      firehose.publish({
        title: error.title,
        no: error.no
      }.to_json).to("/errors/#{error._id}")
    rescue Exception => exc
    end

  end
end
