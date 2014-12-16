#coding: utf-8
require 'log4r/outputter/outputter'
require 'fluent-logger'

module Log4r
  class FluentPostOutputter < Log4r::Outputter
    
    def initialize(_name, hash={})
      super(_name, hash)
      @tag = hash[:tag] || hash["tag"] || 'test'
      host = hash[:host] || hash["host"] || 'localhost'
      port = hash[:port] || hash["port"] || 24224
      @log = Fluent::Logger::FluentLogger.new(nil, host: host, port: port.to_i)
    end
  
    def canonical_log(logevent)
      # body = {l: logevent.level, d: logevent.data}
      content = Log4r::MDC.get_context().merge({level: LNAMES[logevent.level], content: logevent.data})
      @log.post(@tag, content)
    end
  end
end