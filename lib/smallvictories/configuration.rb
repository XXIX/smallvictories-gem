require 'yaml'

module SmallVictories
  class Configuration
    attr_accessor :config

    def initialize
      self.config = if File.exists?('_config.yml')
        YAML.load(File.read('_config.yml')) || {}
      else
        {}
      end
    end

    def config_file key
      config[key.to_s].chomp("/").reverse.chomp("/").reverse if config.has_key?(key.to_s)
    end

    def source
      config_file(:source) || DEFAULT_SOURCE
    end

    def full_source_path
      "#{ROOT}/#{source}"
    end

    def destination
      config_file(:destination) || DEFAULT_DESTINATION
    end

    def full_destination_path
      "#{ROOT}/#{destination}/"
    end

    def javascript
      config_file(:javascript) || DEFAULT_JAVASCRIPT
    end

    def stylesheet
      config_file(:stylesheet) || DEFAULT_STYLESHEET
    end

    def layout
      config_file(:layout) || DEFAULT_LAYOUT
    end

    def includes
      config_file(:includes) || DEFAULT_INCLUDES
    end
  end
end
