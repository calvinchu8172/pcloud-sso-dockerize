module Services
  module RakeLogger

    # This log method is using log4r
    def self.log4r

      require 'log4r'
      include Log4r

      rake_log = Logger.new('rake_log')
      stdout = Outputter.stdout
      file_output = FileOutputter.new('cron', :filename =>  'log/cron.log')

      format = PatternFormatter.new(:pattern => '[%l] %d :: %m', :date_pattern => '%Y/%m/%d %H:%M:%S:%L %Z')

      file_output.formatter = format
      stdout.formatter = format

      rake_log.add(file_output, stdout)

      rake_log.level = Log4r::DEBUG

      return rake_log

    end

    # This log method is using Rails logger
    def self.rails_log

      log_file = File.new("log/cron.log", "a")
      Rails.logger = Logger.new(MultiIO.new(STDOUT, log_file)) #Multi-output to stdout and log file
      rake_log = Rails.logger


      rake_log.formatter = proc do |severity, datetime, progname, msg|
        "[#{severity}] #{datetime.strftime('%Y/%m/%d %H:%M:%S:%L %Z')} :: #{msg}\n"
      end

      rake_log.level = Logger::DEBUG

      return rake_log
    end

  end

end

class MultiIO
  def initialize(*targets)
    @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end


