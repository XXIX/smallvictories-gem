require 'yaml'

module SmallVictories
  class Builder
    attr_accessor :config
    attr_accessor :folder

    def initialize attributes={}
      self.config = attributes[:config]
    end

    def setup folder=nil
      self.folder = "#{folder.chomp("/").reverse.chomp("/").reverse}/" if folder
      setup_directory folder_path
      setup_directory folder_source_path
      setup_config
      setup_stylesheet
      setup_javascript
      setup_html
    end

    def folder_path
      "#{ROOT}/#{folder}"
    end

    def folder_source_path
      "#{folder_path}/#{config.source}/"
    end

    private

    def src_directory
      spec = Gem::Specification.find_by_name("smallvictories")
      "#{spec.gem_dir}/src/"
    end

    def create_src_file source, destination
      unless File.exists?(destination)
        contents = File.open("#{src_directory}#{source}").read
        File.open(destination, 'w') { |file| file.write(contents) }
        SmallVictories.logger.info "created #{destination}"
      end
    end

    def setup_directory path
      unless File.exists?(path)
        Dir.mkdir(path)
        SmallVictories.logger.info "created #{path}"
      end
    end

    def setup_config
      d = YAML::load_file("#{src_directory}config.yml")
      d['source'] = DEFAULT_SOURCE
      d['destination'] = DEFAULT_DESTINATION
      d['stylesheet'] = DEFAULT_STYLESHEET
      d['javascript'] = DEFAULT_JAVASCRIPT
      d['layout'] = DEFAULT_LAYOUT
      d['includes'] = DEFAULT_INCLUDES
      File.open("#{folder_path}#{CONFIG_FILE}", 'w') {|f| f.write d.to_yaml }
    end

    def setup_stylesheet
      create_src_file('stylesheet.css', "#{folder_source_path}#{config.stylesheet}")
    end

    def setup_javascript
      create_src_file('javascript.js', "#{folder_source_path}#{config.javascript}")
    end

    def setup_html
      setup_directory("#{folder_source_path}#{config.includes}")
      create_src_file('head.liquid', "#{folder_source_path}#{config.includes}/_head.liquid")
      create_src_file('layout.liquid', "#{folder_source_path}#{config.layout}")
      create_src_file('index.liquid', "#{folder_source_path}index.liquid")
    end
  end
end
