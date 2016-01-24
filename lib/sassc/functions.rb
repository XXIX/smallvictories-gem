require 'sprockets/sass_functions'
require 'sassc'

module Sprockets
  module SassFunctions
    def asset_data_url(path)
      SassC::Script::String.new("url(" + sprockets_context.asset_data_uri(path.value) + ")")
    end
  end
end

::SassC::Script::Functions.send :include, Sprockets::SassFunctions
