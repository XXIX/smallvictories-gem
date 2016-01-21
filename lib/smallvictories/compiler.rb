module SmallVictories
  class Compiler
    attr_accessor :config

    def initialize attributes={}
      self.config = attributes[:config]
    end

    def package
      sprockets = Sprockets::Environment.new(ROOT) do |environment|
        environment.js_compressor  = :uglify
        environment.css_compressor = :scss
      end

      sprockets.append_path(config.full_stylesheets_path)
      sprockets.append_path(config.full_javascripts_path)

      [config.stylesheet, config.javascript].each do |bundle|
        begin
          assets = sprockets.find_asset(bundle)
          prefix, basename = assets.pathname.to_s.split('/')[-2..-1]
          FileUtils.mkpath config.full_destination_path
          assets.write_to "#{config.full_destination_path}#{basename}"
          SmallVictories.logger.info "👍  packaged #{config.destination}/#{basename}"
        rescue => e
          SmallVictories.logger.error "🔥 🔥 🔥 \n#{e}"
        end
      end
    end
  end
end
