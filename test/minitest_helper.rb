require 'minitest/autorun'
require 'wrong/modern'

require 'awesome_print'
require 'pry-byebug'

require 'fastly_nsq'

class Minitest::Test
  def assert_nothing_raised(&block)
    flunk "Must pass a block" if block.nil?

    passing, msg = true, ''

    begin
      block.call()
    rescue => err
      passing = false
      msg = "Expected nothing to be raised, but instead #{err.inspect}"
    end

    assert passing, msg
  end
end
