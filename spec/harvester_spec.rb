require 'spec_helper'

describe "Harvester" do
  before(:all) do
    @app = FactoryGirl.create(:app, id: '123456')
  end

  describe 'check app key' do

    context 'when we have incorrect app key' do
      it "should call certain methods" do
        Logger.any_instance.expects(:error).once
        Crashlog.any_instance.expects(:save).never
        Logger.any_instance.expects(:info).never
        Resque.expects(:enqueue).never
        header 'X_CRASHDESK_APPKEY', '654321'
        post '/v1/crashes'
      end
      it "shouldn't change count of logs" do
        lambda {
          header 'X_CRASHDESK_APPKEY', '654321'
          post '/v1/crashes'
        }.should_not change(Crashlog, :count)
      end
    end

    context 'when we have correct app key' do
      before do
        JSON.stubs(:parse).returns({error: 'Error', crc: '324j432'})
      end
      it "should call certain methods" do
        @log = stub(id: '342jkl23424', error: 'Error', crc: '324j432', save: true)
        @log.expects(:save).once
        Crashlog.expects(:new).returns(@log)
        Logger.any_instance.expects(:error).never
        Logger.any_instance.expects(:info).once
        Resque.expects(:enqueue).once.with(CrashlogProcessor, @log.id).returns(true)
        header 'X_CRASHDESK_APPKEY', '123456'
        post '/v1/crashes'
      end
      it "should change count of logs" do
        lambda {
          header 'X_CRASHDESK_APPKEY', '123456'
          post '/v1/crashes'
        }.should change(Crashlog, :count).by(1)
      end
    end

  end

end
