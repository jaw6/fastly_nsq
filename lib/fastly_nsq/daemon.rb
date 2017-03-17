require 'typhoeus'
require 'uri'

module FastlyNsq::Daemon
  module_function

  def get(uri, **params)
    request(url, **params).get
  end
  
  def post(uri, **params)
    request(url, **params).post
  end
  
  def request(uri, **params)
    url = URI.join host, uri
    Request.new(url, **params)
  end
  
  class Request
    def initialize(url, **params)
      @url    = url
      @params = params
    end
    
    def data
      if parsed_body.respond_to?(:keys)
        parsed_body['data']
      else
        parsed_body
      end
    end

    def parsed_body
      @parsed_body ||= begin
        JSON.parse response.body
      rescue JSON::ParserError
        response.body
      end
    end
    
    def to_s
      TO_S_TEMPLATE % {
        body:          data,
        effective_url: response.effective_url,
        status_code:   response.code
      }
    end
    
    attr_reader :response, :url
    
    TO_S_TEMPLATE = <<-TEMPLATE
      Status: %{status_code}
      Effective URL: %{effective_url}
      Body:
      %{data}
    TEMPLATE
  end
end

module FastlyNsq::Lookupd < FastlyNsq::Daemon
  def channels(topic:)
    get 'channels', topic: topic
  end
  
  def info
    get 'info'
  end
  
  def lookup(topic: )
    get 'lookup', topic: topic
  end
  
  def nodes
    get 'nodes'
  end
  
  def topics
    get 'topics'
  end

  def host
    "http://#{ENV.fetch('NSQLOOKUPD_HTTP_ADDRESS', '').split(',')[0]}"
  end
end

module FastlyNsq::Nsqd < FastlyNsq::Daemon
  module_function
  
  def info(lookup: false)
    get 'info'
  end
  
  def stats
    get 'stats'
  end

  def empty(topic:, channel: false)
    if channel
      post '/channel/empty', topic: topic, channel: channel
    else
      post '/topic/empty', topic: topic
    end
  end

  def empty_all
  end

  def host
  end
end
