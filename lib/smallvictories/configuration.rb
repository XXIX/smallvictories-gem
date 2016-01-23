require 'yaml'

module SmallVictories
  class Configuration
    attr_accessor :config

    def initialize
      self.config = if File.exists?(CONFIG_FILE)
        YAML.load(File.read(CONFIG_FILE)) || {}
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
      File.join(ROOT, source)
    end

    def destination
      config_file(:destination) || DEFAULT_DESTINATION
    end

    def full_destination_path
      File.join(ROOT, destination)
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

    def full_layout_path
      File.join(full_source_path, layout)
    end

    def includes
      config_file(:includes) || DEFAULT_INCLUDES
    end

    def full_includes_path
      File.join(full_source_path, includes)
    end
  end
end
