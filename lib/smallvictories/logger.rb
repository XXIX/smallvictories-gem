module SmallVictories
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
        log.formatter = proc do |severity, datetime, progname, msg|
          string = "Small Victories: "
          case severity
          when 'INFO'
            string.concat("👍  ")
          when 'WARN'
            string.concat("⚠️  ")
          when 'ERROR'
            string.concat("🔥  ")
          end
          string.concat("#{msg}\n")
        end
      end
    end
  end
end
