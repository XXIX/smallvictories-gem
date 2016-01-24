require 'tilt'

module Sprockets
	module Sassc

		# Static class that we use to share sourcemap
		# caches with the outside world.
		class SourcemapCache

	  		@@cache = {}


	  		def self.set_cache(new_cache)
	  			@@cache = new_cache
	  		end


	  		def self.get_cache
	  			@@cache
	  		end


	  		def self.add(key, value)
	  			@@cache[key] = value
	  		end


	  		def self.get(key)
	  			@@cache[key]
	  		end


	  		def self.has_key?(key)
	  			@@cache.has_key?(key)
	  		end


	  	end




		class SassTemplate < Tilt::SassTemplate
			self.default_mime_type = 'text/css'

			# A reference to the current Sprockets context
			attr_reader :context

			# Determines if the Sass functions have been initialized.
			# They can be 'initialized' without actually being added.
			@sass_functions_initialized = false
			class << self
				attr_accessor :sass_functions_initialized
				alias :sass_functions_initialized? :sass_functions_initialized

				# Templates are initialized once the functions are added.
				def engine_initialized?
					super && sass_functions_initialized?
				end
			end

			# Add the Sass functions if they haven't already been added.
			def initialize_engine
				super unless self.class.superclass.engine_initialized?

				if Sassc.add_sass_functions != false
					# begin
					# 	require 'sprockets/helpers'
						require 'sprockets/sassc/functions'
					# rescue LoadError; end
				end

				self.class.sass_functions_initialized = true
			end

			# Define the expected syntax for the template
			def syntax
				:sass
			end

			# See `Tilt::Template#prepare`.
			def prepare
				@context = nil
				@output  = nil
			end

			# See `Tilt::Template#evaluate`.
			def evaluate(context, locals, &block)
				@output ||= begin
					@context = context

					# render the data to css and optional sourcemap
					render_data(data, context, locals)

				rescue ::Sass::SyntaxError => e
					# Annotates exception message with parse line number
					context.__LINE__ = e.sass_backtrace.first[:line]
					raise e
				end
			end

			protected


			# Custom method to choose how to render the file -
			# either with or without sourcemaps.
			def render_data(data, context, locals)
				if (!data.strip.empty?)
					# The sassc *must* be called with content, an empty string fails.
					css = ::SassC::Engine.new(data, sass_options).render()
				else
					css = ''
				end
				
				css
			end


			# Returns a Sprockets-aware cache store for Sass::Engine.
			def cache_store
				return nil if context.environment.cache.nil?

				if defined?(Sprockets::SassCacheStore)
					Sprockets::SassCacheStore.new context.environment
				else
					CacheStore.new context.environment
				end
			end

			# Assemble the options for the `Sass::Engine`
			def sass_options
				# NOTE: For Sassc importer is now a **class** and not an instance.

				# Allow the use of custom SASS importers, making sure the
				# custom importer is a `Sprockets::Sass::Importer`
				if default_sass_options.has_key?(:importer) &&
					 (default_sass_options[:importer] <= Importer)	# Check if the :importer class is Importer or inherits from Importer
					importer = default_sass_options[:importer]
				else
					# Pass the Importer class
					importer = Importer
				end

				merge_sass_options(default_sass_options, options).merge(
					:filename    => eval_file,
					# :line        => line,
					:syntax      => syntax,
					:cache_store => cache_store,
					:importer    => importer,

					sprockets:      { context: context },
					:custom      => { :sprockets_context => context }
				)
			end

			# Get the default, global Sass options. Start with Compass's
			# options, if it's available.
			def default_sass_options
				# if defined?(Compass)
				# 	merge_sass_options Compass.sass_engine_options.dup, Sprockets::Sassc.options
				# else
				# 	Sprockets::Sassc.options.dup
				# end
				
				# Disable Compass defaults.
				Sprockets::Sassc.options.dup
			end

			# Merges two sets of `Sass::Engine` options, prepending
			# the `:load_paths` instead of clobbering them.
			def merge_sass_options(options, other_options)
				if (load_paths = options[:load_paths]) && (other_paths = other_options[:load_paths])
					other_options[:load_paths] = other_paths + load_paths
				end
				options.merge other_options
			end
		end
	end
end
