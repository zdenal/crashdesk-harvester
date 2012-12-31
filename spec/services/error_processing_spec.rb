require 'spec_helper'

describe Services::ErrorProcessing do

  let(:log) { Crashlog.new(YAML.load(File.read('spec/cassettes/crashlog.yml'))) }
  let(:error_service) { Services::ErrorProcessing.new(log) }
  before(:all) do
    @app = FactoryGirl.create(:app, id: log.app_key)
  end

  context "when error doesn't exist for app" do
    it "create new error with error detail" do
      expect {
        error_service.run
      }.to change{@app.reload.error_info.count}.from(0).to(1)
      @app.error_info.first.error_details.count.should eql(1)
    end
  end

  context "when error exists for app" do
    it "shouldn't create new error" do
      expect {
        error_service.run
      }.not_to change{@app.reload.error_info.count}
    end
    it "should create error detail for error info" do
      @app.error_info.first.error_details.count.should eql(2)
    end
  end

end

