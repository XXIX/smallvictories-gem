require 'socket'
require 'uri'
require 'liquid'
require 'mime-types'
require 'sass'
require 'sassc'


module SmallVictories
  class Server
    attr_accessor :config, :socket, :server

    # Files will be served from this directory
    WEB_ROOT = './'
    TEMP_FILE = './.sv_temp'

    # Treat as binary data if content type cannot be found
    DEFAULT_CONTENT_TYPE = 'application/octet-stream'

    # This helper function parses the extension of the
    # requested file and then looks up its content type.

    def initialize attributes={}
      self.config = attributes[:config]
    end

    def content_type(path)
      if ext = File.extname(path).split(".").last
        MIME::Types.type_for(ext).first.to_s
      else
        'text/html'
      end
    end

    # This helper function parses the Request-Line and
    # generates a path to a file on the server.

    def requested_file(request_line)
      request_uri  = request_line.split(" ")[1]
      path         = URI.unescape(URI(request_uri).path)

      clean = []

      # Split the path into components
      parts = path.split("/")

      parts.each do |part|
        # skip any empty or current directory (".") path components
        next if part.empty? || part == '.'
        # If the path component goes up one directory level (".."),
        # remove the last clean component.
        # Otherwise, add the component to the Array of clean components
        part == '..' ? clean.pop : clean << part
      end

      # return the web root joined to the clean path
      File.join(WEB_ROOT, *clean)
    end

    # This helper function saves the string to
    # a temp file and streams it

    def render_file file, content_type=nil
      socket.print "HTTP/1.1 200 OK\r\n" +
                  "Content-Type: #{content_type || content_type(file)}\r\n" +
                  "Content-Length: #{file.size}\r\n" +
                  "Connection: close\r\n"

      socket.print "\r\n"

      # write the contents of the file to the socket
      IO.copy_stream(file, socket)
    end

    def render_string string, content_type=nil
      File.open(TEMP_FILE, "w") do |f|
        f.write(string)
        f.close
      end

      File.open(TEMP_FILE, "rb") { |f| render_file(f, content_type) }
    end

    def render_stylesheet
      if File.exist?(File.join(WEB_ROOT, '_sv_custom.scss'))
        begin
          engine = Sass::Engine.new(File.open(File.join(WEB_ROOT, '_sv_custom.scss')).read, syntax: :scss)
          render_string(engine.render, 'text/css')
        rescue => e
          socket.print e
        end
      elsif File.exist?(File.join(WEB_ROOT, '_sv_custom.sass'))
        begin
          engine = Sass::Engine.new(File.open(File.join(WEB_ROOT, '_sv_custom.sass')).read, syntax: :sass)
          render_string(engine.render, 'text/css')
        rescue => e
          socket.print e
        end
      elsif File.exist?(File.join(WEB_ROOT, '_sv_custom.css'))
        # Open _sv_custom.css
        File.open(File.join(WEB_ROOT, '_sv_custom.css'), "rb") do |file|
          render_file(file)
        end
      end
    end

    def run
      # Except where noted below, the general approach of
      # handling requests and generating responses is
      # similar to that of the "Hello World" example
      # shown earlier.

      @server = TCPServer.new('localhost', 2345)

      loop do
        @socket = @server.accept
        request_line = socket.gets

        STDERR.puts request_line

        begin
          path = requested_file(request_line)
          path = File.join(path, 'index.html') if File.directory?(path)

          if path == File.join(WEB_ROOT, '_sv_custom.css')
            render_stylesheet
          elsif File.exist?(path) && !File.directory?(path)
            File.open(path, "rb") do |file|
              if File.extname(path) == '.html'
                # parse liquid
                template = Liquid::Template.parse(file.read, error_mode: :warn)
                render_string(template.render(SiteFile.files_hash))
              else
                render_file(file)
              end
            end
          else
            message = "File not found\n"

            # respond with a 404 error code to indicate the file does not exist
            socket.print "HTTP/1.1 404 Not Found\r\n" +
                        "Content-Type: text/plain\r\n" +
                        "Content-Length: #{message.size}\r\n" +
                        "Connection: close\r\n"

            socket.print "\r\n"

            socket.print message
          end
        rescue => e
          socket.print "\r\n"
        end

        socket.close
      end
    end
  end
end
