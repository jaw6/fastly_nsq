require 'typhoeus'
require 'uri'

module FastlyNsq::Manager
  module_function

  def channels(topic:)
    get_via_lookup 'channels', topic: topic
  end
  
  def info(lookup: false)
    if lookup
      get_via_lookup 'info'
    else
      get 'info'
    end
  end
  
  def lookup(topic: )
    get_via_lookup 'lookup', topic: topic
  end
  
  def nodes
    get_via_lookup 'nodes'
  end
  
  def stats
    get 'stats'
  end
  
  def topics
    get_via_lookup 'topics'
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

  def get(uri, **params)
    Request.new url, **params
  end
  
  def get_via_lookup(uri, **params)
    url = URI.join first_configured_lookupd, uri
    Request.new url, **params
  end
  
  def post(uri, **params)
    Request.new url, **params
  end
  
  def first_configured_lookupd
    "http://#{ENV.fetch('NSQLOOKUPD_HTTP_ADDRESS', '').split(',')[0]}"
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
