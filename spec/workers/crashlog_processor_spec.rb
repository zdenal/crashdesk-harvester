require 'spec_helper'

describe CrashlogProcessor do

  let(:log) {FactoryGirl.create(:crashlog)}

  describe '::perform' do
    it "should call certain methods" do
      service = stub('service')
      Services::ErrorProcessing.expects(:new).with(log)\
        .once.returns(service)
      service.expects(:run).once
      CrashlogProcessor.perform(log.id)
    end
  end
end
