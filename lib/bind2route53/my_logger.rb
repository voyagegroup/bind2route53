module Bind2Route53
  class MyLogger
    def initialize(logfile)
      logfile = '/dev/null' if logfile.nil?
      @logger_logfile = Logger.new(logfile)
      @logger_logfile.level = Logger::INFO

      @logger_logfile.formatter = proc do |severity, datetime, progname, message|
        "[#{Time.now}]#{message}\n"
      end
    end

    def info(msg = "")
      puts msg
      @logger_logfile.info(msg)
    end

    def warn(msg = "")
      puts msg
      @logger_logfile.warn(msg)
    end

    def error(msg = "")
      puts msg
      @logger_logfile.error(msg)
    end
  end
end
