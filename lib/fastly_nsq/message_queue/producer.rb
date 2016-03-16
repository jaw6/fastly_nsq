class InvalidParameterError < StandardError; end

module MessageQueue
  class Producer
    def initialize(topic:)
      @topic = topic
    end

    def connection
      @producer ||= producer.new(params)
    end

    def terminate
      @producer.terminate
    end

    private

    attr_reader :topic

    def producer
      Strategy.for_queue::Producer
    end

    def params
      {
        nsqd: ENV.fetch('NSQD_TCP_ADDRESS'),
        topic: topic,
      }
    end
  end
end
