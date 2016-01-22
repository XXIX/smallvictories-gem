require 'listen'

module SmallVictories
  class Watcher
    attr_accessor :compiler

    def initialize attributes={}
      self.compiler = attributes[:compiler]
    end

    def build_listener
      Listen.to(
        compiler.config.full_source_path,
        force_polling: true,
        ignore: [/#{compiler.config.destination}/],
        &(listen_handler)
      )
    end

    def listen_handler
      proc do |modified, added, removed|
        paths = modified + added + removed
        extensions = paths.map{ |path| File.extname(path) }
        extensions.uniq.each do |ext|
          case ext
          when '.scss', '.sass', '.css'
            compiler.compile_css
          when '.coffee', '.js'
            compiler.compile_js
          when '.liquid', '.html'
            compiler.compile_html
          else
          end
        end
      end
    end

    def watch
      listener = build_listener
      listener.start
      SmallVictories.logger.debug "👋"
      SmallVictories.logger.debug "👀"

      trap("INT") do
        listener.stop
        SmallVictories.logger.warn "✋  Halting auto-regeneration."
        exit 0
      end

      sleep_forever
    rescue ThreadError
      # Ctrl-C
    end

    def sleep_forever
      loop { sleep 1000 }
    end
  end
end
