module Sprockets
  module Sassc
  	
    class ScssTemplate < SassTemplate
      self.default_mime_type = 'text/css'
      
      # Define the expected syntax for the template
      def syntax
        :scss
      end
      
    end
  end
end
