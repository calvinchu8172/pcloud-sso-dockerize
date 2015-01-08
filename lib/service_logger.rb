require 'fluent-logger'

module Fluent
  module Logger

  	mattr_accessor :logger_name, :fluent_logger, :tag, :host, :port

    def self.setup

      yield self

      log4r = Log4r::Logger[@@logger_name]
      @@service_logger = ServiceLogger.new() 
    end

    def self.service_logger
      @@service_logger
    end

  	class ServiceLogger

      def initialize()
      	super( nil, hash)
      end

      def note(content)
      	
      	param = Log4r::MDC.get_context().merge(content)
      end
  	end
  end
end