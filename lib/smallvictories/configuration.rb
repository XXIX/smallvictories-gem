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

    def config_folder key
      config[key.to_s].chomp("/").reverse.chomp("/").reverse if config.has_key?(key.to_s)
    end

    def source
      config_folder(:source) || DEFAULT_SOURCE
    end

    def full_source_path
      "#{ROOT}/#{source}"
    end

    def destination
      config_folder(:destination) || DEFAULT_DESTINATION
    end

    def full_destination_path
      "#{ROOT}/#{destination}/"
    end

    def stylesheets_dir
      config_folder(:stylesheets_dir) || DEFAULT_STYLESHEET_DIR
    end

    def full_stylesheets_path
      "#{full_source_path}/#{stylesheets_dir}/"
    end

    def javascripts_dir
      config_folder(:javascripts_dir) || DEFAULT_JAVASCRIPT_DIR
    end

    def full_javascripts_path
      "#{full_source_path}/#{javascripts_dir}/"
    end

    def javascript
      config_folder(:javascript) || DEFAULT_JAVASCRIPT
    end

    def full_javascript_path
      "#{full_javascripts_path}/#{javascript}"
    end

    def stylesheet
      config_folder(:stylesheet) || DEFAULT_STYLESHEET
    end

    def full_stylesheet_path
      "#{full_stylesheets_path}/#{stylesheet}"
    end

    def setup
      setup_stylesheet
      setup_javascript
    end

    private

    def create_src_file source, destination
      spec = Gem::Specification.find_by_name("smallvictories")
      contents = File.open("#{spec.gem_dir}/src/#{source}").read
      File.open(destination, 'w') { |file| file.write(contents) }
    end

    def setup_directory path
      Dir.mkdir(path) unless File.exists?(path)
    end

    def setup_stylesheet
      setup_directory(full_stylesheets_path)
      unless File.exists?(full_stylesheet_path)
        create_src_file('stylesheet.css', full_stylesheet_path)
      end
    end

    def setup_javascript
      setup_directory(full_javascripts_path)
      unless File.exists?(full_javascript_path)
        create_src_file('javascript.js', full_javascript_path)
      end
    end
  end
end
