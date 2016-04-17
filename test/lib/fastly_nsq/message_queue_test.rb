require 'minitest_helper'

describe MessageQueue do
  describe '.logger' do
    let(:logger) { Logger.new STDOUT }

    it 'allows the logger to be set and retrieved' do
      MessageQueue.logger = logger
      assert { MessageQueue.logger == logger }
    end
  end
end
