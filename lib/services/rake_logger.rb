module Services
  module RakeLogger

    # This log method is using log4r
    def self.log4r

      require 'log4r'
      include Log4r

      rake_log = Logger.new 'mylog'
      stdout = Outputter.stdout
      file_output = FileOutputter.new('cron', :filename =>  'log/cron.log')

      format = PatternFormatter.new(:pattern => '[%l] %d :: %m', :date_pattern => '%Y/%m/%d %H:%M:%S:%L')

      file_output.formatter = format
      stdout.formatter = format

      rake_log.add(file_output, stdout)

      rake_log.level = Log4r::DEBUG

      return rake_log

    end

    # This log method is using Rails logger
    def self.log
      # @rake_log = Logger.new(STDOUT) #output to console
      rake_log = Logger.new("log/cron.log")
      rake_log.datetime_format = '%Y-%m-%d %H:%M:%S'
      rake_log.level = Logger::DEBUG
      return rake_log
    end

  end
end


