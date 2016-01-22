require 'sprockets'
require 'autoprefixer-rails'
require 'liquid'

module SmallVictories
  class Compiler
    attr_accessor :config

    def initialize attributes={}
      self.config = attributes[:config]
    end

    def compile_css
      package  [config.stylesheet]
      prefix_css
    end

    def compile_js
      package  [config.javascript]
    end

    def compile_html
      liquid
    end

    def liquid
      begin
        Liquid::Template.file_system = Liquid::LocalFileSystem.new("#{config.full_source_path}/#{config.includes}")
        layout_path = "#{config.full_source_path}/#{config.layout}"
        if File.exists?(layout_path)
          layout_file = File.open(layout_path).read
          layout = Liquid::Template.parse(layout_file)
        end
      rescue => e
        SmallVictories.logger.error "Liquid Error\n#{e}"
        return
      end

      Dir.glob(["#{config.full_source_path}/*.html", "#{config.full_source_path}/*.liquid"]) do |path|
        begin
          file_name = Pathname.new(path).basename.to_s.split('.').first
          next if file_name =~ /^_/ # do not render partials

          file = File.open(path).read
          liquid = Liquid::Template.parse(file)
          content = liquid.render('config' => { 'stylesheet' => config.stylesheet, 'javascript' => config.javascript })
          output_file_name = file_name.concat('.html')
          output_path = "#{config.full_destination_path}#{output_file_name}"
          if layout
            html = layout.render('content_for_layout' => liquid.render, 'config' => { 'stylesheet' => config.stylesheet, 'javascript' => config.javascript })
          else
            html = liquid.render('config' => { 'stylesheet' => config.stylesheet, 'javascript' => config.javascript })
          end
          File.open("#{config.full_destination_path}#{output_file_name}", 'w') { |file| file.write(html) }
          SmallVictories.logger.info "compiled #{config.destination}/#{output_file_name}"
        rescue => e
          SmallVictories.logger.error "#{path}\n#{e}"
        end
      end
    end
    def package bundles=[config.stylesheet, config.javascript]
      sprockets = Sprockets::Environment.new(ROOT) do |environment|
        environment.js_compressor  = :uglify
        environment.css_compressor = :scss
      end

      sprockets.append_path(config.full_source_path)
      bundles.each do |bundle|
        begin
          if assets = sprockets.find_asset(bundle)
            prefix, basename = assets.pathname.to_s.split('/')[-2..-1]
            FileUtils.mkpath config.full_destination_path
            assets.write_to "#{config.full_destination_path}#{basename}"
            SmallVictories.logger.info "compiled #{config.destination}/#{basename}"
          end
        rescue => e
          SmallVictories.logger.error "#{bundle}\n#{e}"
        end
      end
    end

    def prefix_css
      begin
        path = "#{config.full_destination_path}#{config.stylesheet}"
        css = File.open(path).read
        prefixed = AutoprefixerRails.process(css, browsers: ['last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1'], cascade: false)
        File.open(path, 'w') { |file| file.write(prefixed.css) }

        sprockets = Sprockets::Environment.new(ROOT) do |environment|
          environment.css_compressor = :scss
        end
        sprockets.append_path(config.full_destination_path)
        assets = sprockets.find_asset(config.stylesheet)
        assets.write_to "#{config.full_destination_path}#{config.stylesheet}"

        SmallVictories.logger.info "prefixed #{config.destination}/#{config.stylesheet}"
      rescue => e
        SmallVictories.logger.error "#{path}\n#{e}"
      end
    end
  end
end
