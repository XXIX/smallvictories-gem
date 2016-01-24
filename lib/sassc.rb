require 'sprockets'
require 'sprockets/sassc/sass_template'
require 'sprockets/sassc/scss_template'
require 'sprockets/engines'
require 'sassc'

module Sprockets
  module Sassc
    autoload :CacheStore, 'sprockets/sassc/cache_store'
    autoload :Compressor, 'sprockets/sassc/compressor'
    autoload :Importer,   'sprockets/sassc/importer'

    class << self
      # Global configuration for `Sass::Engine` instances.
      attr_accessor :options

      # When false, the asset path helpers provided by
      # sprockets-helpers will not be added as Sass functions.
      # `true` by default.
      attr_accessor :add_sass_functions
    end

    @options = {}
    @add_sass_functions = true
  end

  register_engine :sass, Sassc::SassTemplate
  register_engine :scss, Sassc::ScssTemplate
end
