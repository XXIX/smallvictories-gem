require "smallvictories/version"
require 'yaml'
require 'sassc'
require 'sprockets'
require 'listen'

module SmallVictories
  extend self
  DEFAULT_SASS_DIR = '_sass'
  DEFAULT_STYLESHEET = '_sv_custom.css'
  DEFAULT_CSS_DIR = '_css'
  DEFAULT_SOURCE = ''
  DEFAULT_DESTINATION = '_site'
  ROOT = Dir.pwd

  def hello
    "Hello World!"
  end

  def config
    if File.exists?('_config.yml')
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

  def css_dir
    config_folder(:css_dir) || DEFAULT_CSS_DIR
  end

  def full_css_path
    "#{full_source_path}/#{css_dir}/"
  end

  def stylesheet
    config_folder(:stylesheet) || DEFAULT_STYLESHEET
  end

  def full_stylesheet_path
    "#{full_css_path}/#{stylesheet}"
  end

  def sass_dir
    config_folder(:sass_dir) || DEFAULT_SASS_DIR
  end

  def full_sass_path
    "#{full_source_path}/#{sass_dir}/"
  end

  def full_sass_path
    "#{full_source_path}/#{sass_dir}/"
  end

  def build_listener
    Listen.to(
      full_source_path,
      force_polling: true,
      &(listen_handler)
    )
  end

  def listen_handler
    proc do |modified, added, removed|
      paths = modified + added + removed
      extensions = paths.map{ |path| File.extname(path) }
      extensions.each do |ext|
        case ext
        when '.scss'
          puts sass
          puts compile
        when '.sass'
          puts sass
          puts compile
        else
        end
      end
    end
  end

  def setup
    setup_stylesheet
  end

  def watch
    listener = build_listener
    listener.start
    puts "👀"

    trap("INT") do
      listener.stop
      puts "🔥 🔥 🔥  Halting auto-regeneration."
      exit 0
    end

    sleep_forever
  rescue ThreadError
    # Ctrl-C
  end

  def sass
    errors, rendered = [], []
    Dir.glob([full_sass_path.concat('*.scss'), full_sass_path.concat('*.sass')]) do |path|
      begin
        file_name = Pathname.new(path).basename.to_s.split('.').first
        next if file_name =~ /^_/ # do not render partials
        file = File.open(path).read
        engine = SassC::Engine.new(file, { style: :compressed, load_paths: [full_sass_path] })
        css = engine.render
        output_file_name = file_name.concat('.css')
        output_path = full_css_path.concat(output_file_name)
        File.open(output_path, 'w') { |file| file.write(css) }
        rendered << "👍  rendered #{destination.concat('/').concat(css_dir).concat('/').concat(output_file_name)}\n"
      rescue => e
        errors << "🔥  Sass 🔥  #{e}\n"
      end
    end
    rendered.join(', ') + errors.join(', ')
  end

  def compile
    sprockets = Sprockets::Environment.new(ROOT) do |environment|
      environment.js_compressor  = :uglify
      environment.css_compressor = :scss
    end

    sprockets.append_path(full_css_path)

    errors, compiled = [], []
    begin
      [stylesheet].each do |bundle|
        assets = sprockets.find_asset(bundle)
        prefix, basename = assets.pathname.to_s.split('/')[-2..-1]
        FileUtils.mkpath full_destination_path.concat(prefix)

        assets.write_to(full_destination_path.concat(basename))
        compiled << "👍  compiled #{destination.concat('/').concat(basename)}\n"
      end
    rescue => e
      puts e.class
      errors << "🔥  Compile 🔥  #{e}\n"
    end
    compiled.join(', ') + errors.join(', ')
  end

  def sleep_forever
    loop { sleep 1000 }
  end

  private

  def create_src_file source, destination
    spec = Gem::Specification.find_by_name("smallvictories")
    contents = File.open(spec.gem_dir.concat('/src/').concat(source)).read
    File.open(destination, 'w') { |file| file.write(contents) }
  end

  def setup_stylesheet
    setup_directory(full_css_path)
    unless File.exists?(full_stylesheet_path)
      create_src_file('stylesheet.css', full_stylesheet_path)
    end
  end

  def setup_directory path
    Dir.mkdir(path) unless File.exists?(path)
  end
end
