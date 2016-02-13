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
      config[key.to_s].to_s.chomp("/").reverse.chomp("/").reverse if config.has_key?(key.to_s)
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

    def source_javascript
      config_file(:source_javascript) || DEFAULT_SOURCE_JAVASCRIPT
    end

    def destination_javascript
      config_file(:destination_javascript) || DEFAULT_DESTINATION_JAVASCRIPT
    end

    def javascripts
      [source_javascript, destination_javascript]
    end

    def source_stylesheet
      config_file(:source_stylesheet) || DEFAULT_SOURCE_STYLESHEET
    end

    def destination_stylesheet
      config_file(:destination_stylesheet) || DEFAULT_DESTINATION_STYLESHEET
    end

    def stylesheets
      [source_stylesheet, destination_stylesheet]
    end

    def source_sprite
      config_file(:source_sprite) || DEFAULT_SOURCE_SPRITE
    end

    def destination_sprite_file
      config_file(:destination_sprite_file) || DEFAULT_DESTINATION_SPRITE_FILE
    end

    def destination_sprite_style
      config_file(:destination_sprite_style) || DEFAULT_DESTINATION_SPRITE_STYLE
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

    def compile_css
      eval config_file(:compile_css) || 'true'
    end

    def compile_html
      eval config_file(:compile_html) || 'true'
    end

    def compile_js
      eval config_file(:compile_js) || 'true'
    end

    def compile_sprite
      eval config_file(:compile_sprite) || 'true'
    end
  end
end
