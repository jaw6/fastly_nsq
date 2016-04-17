module Loggable
  def default_logger
    @default_logger ||= Logger.new(nil)
  end

  attr_writer(:logger)
  def logger
    @logger || default_logger
  end

  def self.included(base)
  end

  def self.extended(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def logger=(logger)
      @logger = logger
    end

    def logger
      @logger || default_logger
    end
  end
end

class ClassWithLoggable
  extend Loggable
end

class InstanceWithLoggable
  include Loggable
end

module ModuleWithLoggable
  extend Loggable
end

require 'minitest_helper'

describe Loggable do
  let(:nil_logger)   { Logger.new(nil) }
  let(:fancy_logger) { Object.new }

  it 'adds a logger accessor on ClassWithLoggable' do
    original_logger = ClassWithLoggable.logger
    ClassWithLoggable.logger = fancy_logger
    assert { original_logger.is_a?(Logger) && ClassWithLoggable.logger == fancy_logger }
    ClassWithLoggable.logger = original_logger
  end

  it 'adds a logger accessor on InstanceWithLoggable' do
    instance = InstanceWithLoggable.new
    other_instance = InstanceWithLoggable.new
    other_instance.logger = fancy_logger
    assert { instance.logger.is_a?(Logger) && other_instance.logger = fancy_logger }
  end

  it 'adds a logger accessor on ModuleWithLoggable' do
    original_logger = ModuleWithLoggable.logger
    ModuleWithLoggable.logger = fancy_logger
    assert { original_logger.is_a?(Logger) && ModuleWithLoggable.logger == fancy_logger }
    ModuleWithLoggable.logger = original_logger
  end

end
