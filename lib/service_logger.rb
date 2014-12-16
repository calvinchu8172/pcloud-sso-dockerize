require 'fluent-logger'
require_relative '../lib/log4r/outputter/fluent_post_outputter'

module Fluent
  module Logger

    DEFAULT_LOGGER_NAME = 'service'
    DEFAULT_FLUENTD_PORT = '24224'

  	mattr_accessor :logger_name, :fluent_logger, :tag, :host, :port

    def self.setup
      yield self

      @@logger_name = DEFAULT_LOGGER_NAME if defined?(@@logger_name)
      @@port = DEFAULT_FLUENTD_PORT if defined?(@@tag)

      log4r = Log4r::Logger[@@logger_name]

      @@service_logger = ServiceLogger.new(@@tag, log4r, host: @@host, port: @@port.to_i) 
    end

    def self.service_logger
      @@service_logger
    end

  	class ServiceLogger < FluentLogger

      def initialize( tag, log4r, hash={})
      	@tag = tag
      	@log4r = log4r
      	super( nil, hash)
      end

      def note(content)
      	
      	param = Log4r::MDC.get_context().merge(content)
      	@log4r.info(param.to_s)
      	post( @tag, param)
      end
  	end
  end
end