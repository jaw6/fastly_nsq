require 'minitest_helper'
require 'fastly_nsq/fake_message_queue'

describe FakeMessageQueue do
  after { FakeMessageQueue.reset! }

  let(:topic) { 'death_star' }
  let(:producer) do
    FakeMessageQueue::Producer.new \
      nsqd: ENV.fetch('NSQD_TCP_ADDRESS'),
      topic: topic
  end

  it 'initializes an empty queue' do
    assert { FakeMessageQueue.queue == [] }
  end

  it 'has a logger' do
    assert { FakeMessageQueue.logger.is_a? Logger }
  end

  describe 'setting logger' do
    before { @original_logger = FakeMessageQueue.logger }
    after  { FakeMessageQueue.logger = @original_logger }

    let(:fake_logger) { Object.new }
    it 'can set logger' do
      FakeMessageQueue.logger = fake_logger
      assert { FakeMessageQueue.logger == fake_logger }
    end
  end

  describe 'resetting the queue' do
    before do
      FakeMessageQueue.queue = ['hello']
      assert { FakeMessageQueue.queue == ['hello'] }
    end

    it 'resets the fake message queue' do
      FakeMessageQueue.reset!
      assert { FakeMessageQueue.queue.empty? }
    end
  end

  describe 'Consumer' do
    let(:channel) { 'star_killer_base' }
    let(:consumer) {
      FakeMessageQueue::Consumer.new \
        nsqlookupd: ENV.fetch('NSQLOOKUPD_HTTP_ADDRESS'),
        channel: channel,
        topic: topic
    }

    describe 'when there no message on the queue' do
      it 'tells you how many messages are in the queue' do
        assert { consumer.size == 0 }
      end

      it 'blocks for longer than the queue check cycle' do
        assert_raises(Timeout::Error) do
          Timeout.timeout(0.2) { consumer.pop(0.1).tap { |x| puts "Popped: #{x.inspect}"} }
        end
      end
    end

    it 'has a terminate method which is a noop' do
      assert_nothing_raised { consumer.terminate }
    end

    describe 'when there is a message on the queue' do
      before { FakeMessageQueue.queue = ['hello'] }

      it 'tells you how many messages are in the queue' do
        assert { consumer.size == 1 }
      end

      it 'returns the last message off of the queue' do
        message = FakeMessageQueue::Message.new('hello')
        FakeMessageQueue.queue = [:not, message]
        assert { consumer.pop == message }
      end
    end


  end

  describe 'Message' do
    describe '#body' do
      let(:content) { 'hello' }

      it 'returns the body of the message' do
        producer.write(content)
        assert { content == FakeMessageQueue.queue.pop.body }
      end
    end

  end

  describe 'Producer' do
    after { FakeMessageQueue.reset! }

    it 'adds a new message to the queue' do
      producer.write('hello')
      assert { FakeMessageQueue.queue.size == 1 }
    end

    it 'has a `terminate` method which is a noop' do
      assert_nothing_raised do
        producer.terminate
      end
    end
  end
end
