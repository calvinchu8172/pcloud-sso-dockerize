module Fluent
  module Logger

  	mattr_accessor :logger_name, :fluent_logger, :tag, :host, :port

    def self.setup

      yield self

      @@service_logger = ServiceLogger.new() 
    end

    def self.service_logger
      @@service_logger
    end

  	class ServiceLogger

      def initialize()
      end

      def note(content)
      	
      end
  	end
  end
end