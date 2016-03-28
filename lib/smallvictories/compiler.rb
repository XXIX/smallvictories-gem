require 'sprockets'
require 'autoprefixer-rails'
require 'liquid'
require 'premailer'
require 'sprite_factory'
require 'rails-sass-images'

module SmallVictories
  class Compiler
    attr_accessor :config

    def initialize attributes={}
      self.config = attributes[:config]
    end

    def compile_css
      package  [config.stylesheets] if config.compile_css
    end

    def compile_js
      package  [config.javascripts] if config.compile_js
    end

    def compile_html
      liquid if config.compile_html
    end

    def compile_sprite
      sprite if config.compile_sprite
    end

    def inline_html
      premail
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
        SmallVictories.logger.error "Liquid Error\n#{e}\n#{e.backtrace.first}"
        return
      end

      Dir.glob([File.join(config.full_source_path, '**/*.html'), File.join(config.full_source_path, '**/*.liquid')]) do |path|
        begin
          pathname = Pathname.new(path)
          file_name = pathname.basename.to_s.split('.').first
          folder_path = pathname.dirname.to_s.gsub(config.full_source_path, '')
          full_output_path = File.join(config.full_destination_path, folder_path)

          next if file_name =~ /^_/ # do not render partials or layout

          file = File.open(path).read
          liquid = Liquid::Template.parse(file)
          stylesheet_path = Pathname.new(config.full_destination_path)
          file_path = Pathname.new(full_output_path)
          relative_path = stylesheet_path.relative_path_from(file_path)

          data = { 'config' => { 'stylesheet' => File.join(relative_path, config.stylesheets.last), 'javascript' => File.join(relative_path, config.javascripts.last) } }
          content = liquid.render(data)
          output_file_name = file_name.concat('.html')
          output_path = File.join(config.full_destination_path, output_file_name)
          if layout
            html = layout.render(data.merge('content_for_layout' => liquid.render))
          else
            html = liquid.render(data)
          end
          Dir.mkdir(full_output_path) unless File.exists?(full_output_path)
          File.open(File.join(full_output_path, output_file_name), 'w') { |file| file.write(html) }
          SmallVictories.logger.info "compiled #{File.join(config.destination, folder_path, output_file_name)}"
        rescue => e
          SmallVictories.logger.error "#{path}\n#{e}\n#{e.backtrace.first}"
        end
      end
    end

    def package bundles=[config.stylesheets, config.javascripts], options={}
      sprockets = Sprockets::Environment.new(config.full_source_path) do |environment|
        environment.gzip = true
        environment.logger = SmallVictories.logger
        environment.js_compressor  = options[:js_compressor] || :uglify
        environment.css_compressor = options[:css_compressor] || :sass
      end
      RailsSassImages.install(sprockets)

      sprockets.append_path('.')
      bundles.each do |bundle|
        begin
          if assets = sprockets.find_asset(bundle.first)
            FileUtils.mkpath config.full_destination_path
            assets.write_to File.join(config.full_destination_path,  bundle.last)
            SmallVictories.logger.info "compiled #{File.join(config.destination, bundle.last)}"
          end
        rescue => e
          SmallVictories.logger.error "#{bundle.first}\n#{e}\n#{e.backtrace.first}"
        end
      end
    end

    def prefix_css
      begin
        path = File.join(config.full_destination_path, config.stylesheets.last)
        css = File.open(path).read
        prefixed = AutoprefixerRails.process(css, browsers: ['last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1'], cascade: false)
        File.open(path, 'w') { |file| file.write(prefixed.css) }

        sprockets = Sprockets::Environment.new(config.full_source_path) do |environment|
          environment.css_compressor = :yui
        end
        sprockets.append_path(config.full_destination_path)
        if assets = sprockets.find_asset(config.stylesheets.last)
          assets.write_to File.join(config.full_destination_path, config.stylesheets.last)
          SmallVictories.logger.info "prefixed #{File.join(config.destination,config.stylesheets.last)}"
        end
      rescue => e
        SmallVictories.logger.error "#{path}\n#{e}\n#{e.backtrace.first}"
      end
    end

    def minify_css
      package  [config.stylesheets]
      prefix_css
    end

    def minify_js
      package [config.javascripts], { js_compressor: :closure }
    end

    def premail
      Dir.glob([File.join(config.full_destination_path, '**/*.html')]) do |path|
        begin
          premailer = Premailer.new(path, warn_level: Premailer::Warnings::SAFE)
          File.open(path, 'w') { |file| file.write(premailer.to_inline_css) }

          # Output any CSS warnings
          premailer.warnings.each do |w|
            SmallVictories.logger.warn "#{w[:message]} (#{w[:level]}) may not render properly in #{w[:clients]}"
          end
          file_name = Pathname.new(path).basename
          SmallVictories.logger.info "inlined #{File.join(config.destination, file_name)}"
          size = File.size(path)
          if size > 102000
            SmallVictories.logger.warn "size is greater than 120kb (#{size})"
          else
            SmallVictories.logger.info "size is less than 120kb (#{size})"
          end
        rescue => e
          SmallVictories.logger.error "Inline Error\n#{e}"
        end
      end
    end

    def sprite
      SmallVictories.logger.debug "Spriting"
      sprite_directory = File.join(config.full_source_path, config.source_sprite)
      return unless Dir.exists?(sprite_directory)
      css = "@import 'rails-sass-images';\n"
      css += SpriteFactory.run!(sprite_directory,
        output_image: File.join(config.full_source_path, config.destination_sprite_file),
        style: :scss,
        margin: 20,
        layout: :vertical,
        nocss: true,
        sanitizer: true) do |images|
          images.map do |image_name, image_data|
            ".sprite-#{image_name} { background-image: url('#{config.destination_sprite_file}'); background-size: (image-width('#{File.join(config.destination_sprite_file)}')/2) auto; background-repeat: no-repeat; background-position: (#{image_data[:cssx]}px/-2) (#{image_data[:cssy]}px/-2); height: (#{image_data[:cssh]}px/2) + 1px; width: (#{image_data[:cssw]}px/2) + 1px;}"
          end.join("\n")
        end
      FileUtils.cp(File.join(config.full_source_path, config.destination_sprite_file), File.join(config.full_destination_path, config.destination_sprite_file))
      File.open(File.join(config.full_source_path, config.destination_sprite_style), 'w') { |file| file.write(css) }
      SmallVictories.logger.info "compiled #{File.join(config.destination, config.destination_sprite_style)}"
    end
  end
end
