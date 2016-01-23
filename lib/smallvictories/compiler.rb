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
    end

    def compile_js
      package  [config.javascript]
    end

    def compile_html
      liquid
    end

    def liquid
      begin
        Liquid::Template.file_system = Liquid::LocalFileSystem.new(config.full_includes_path)
        layout_path = config.full_layout_path
        if File.exists?(layout_path)
          layout_file = File.open(layout_path).read
          layout = Liquid::Template.parse(layout_file)
        end
      rescue => e
        SmallVictories.logger.error "Liquid Error\n#{e}"
        return
      end

      Dir.glob([File.join(config.full_source_path, '*.html'), File.join(config.full_source_path, '*.liquid')]) do |path|
        begin
          file_name = Pathname.new(path).basename.to_s.split('.').first
          next if file_name =~ /^_/ # do not render partials

          file = File.open(path).read
          liquid = Liquid::Template.parse(file)
          content = liquid.render('config' => { 'stylesheet' => config.stylesheet, 'javascript' => config.javascript })
          output_file_name = file_name.concat('.html')
          output_path = File.join(config.full_destination_path, output_file_name)
          if layout
            html = layout.render('content_for_layout' => liquid.render, 'config' => { 'stylesheet' => config.stylesheet, 'javascript' => config.javascript })
          else
            html = liquid.render('config' => { 'stylesheet' => config.stylesheet, 'javascript' => config.javascript })
          end
          Dir.mkdir(config.full_destination_path) unless File.exists?(config.full_destination_path)
          File.open(File.join(config.full_destination_path, output_file_name), 'w') { |file| file.write(html) }
          SmallVictories.logger.info "compiled #{config.destination}/#{output_file_name}"
        rescue => e
          SmallVictories.logger.error "#{path}\n#{e}"
        end
      end
    end

    def package bundles=[config.stylesheet, config.javascript], options={}
      sprockets = Sprockets::Environment.new(ROOT) do |environment|
        environment.gzip = true
        environment.logger = SmallVictories.logger
        environment.js_compressor  = options[:js_compressor] || :uglify
        environment.css_compressor = options[:css_compressor] || :sass
      end

      sprockets.append_path(config.full_source_path)
      bundles.each do |bundle|
        begin
          if assets = sprockets.find_asset(bundle)
            prefix, basename = assets.pathname.to_s.split('/')[-2..-1]
            FileUtils.mkpath config.full_destination_path
            assets.write_to File.join(config.full_destination_path,  basename)
            SmallVictories.logger.info "compiled #{config.destination}/#{basename}"
          end
        rescue => e
          SmallVictories.logger.error "#{bundle}\n#{e}"
        end
      end
    end

    def prefix_css
      begin
        path = File.join(config.full_destination_path, config.stylesheet)
        css = File.open(path).read
        prefixed = AutoprefixerRails.process(css, browsers: ['last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1'], cascade: false)
        File.open(path, 'w') { |file| file.write(prefixed.css) }

        sprockets = Sprockets::Environment.new(ROOT) do |environment|
          environment.css_compressor = :yui
        end
        sprockets.append_path(config.full_destination_path)
        if assets = sprockets.find_asset(config.stylesheet)
          assets.write_to File.join(config.full_destination_path, config.stylesheet)
          SmallVictories.logger.info "prefixed #{config.destination}/#{config.stylesheet}"
        end
      rescue => e
        SmallVictories.logger.error "#{path}\n#{e}"
      end
    end

    def minify_css
      package  [config.stylesheet]
      prefix_css
    end

    def minify_js
      package [config.javascript], { js_compressor: :closure }
    end
  end
end
