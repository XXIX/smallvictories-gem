require 'tilt'
require 'pathname'

require_relative 'default_importer'

# # DEBUG ONLY
# require 'colorize'

module Sprockets
	module Sassc
		class Importer < ::SassC::Importer
			class Extension
				attr_reader :postfix

				def initialize(postfix=nil)
					@postfix = postfix
				end
				
				def import_for(full_path, parent_dir, options)
					SassC::Importer::Import.new(full_path)
				end
			end
			
			class SprocketsExtension < Extension
				def import_for(full_path, parent_dir, options)
					eval_content = evaluate(options[:sprockets][:context], full_path)
					
					# sassc doesn't support sass syntax, convert sass to scss
					# before returning result.
					if Pathname.new(full_path).basename.to_s.include?('.sass')
						eval_content = SassC::Sass2Scss.convert(eval_content)
					end
					# puts "SprocketsExtension: eval_content=#{eval_content}"
					
					SassC::Importer::Import.new(full_path, source: eval_content)
				end
				
				# Returns the string to be passed to the Sass engine. We use
				# Sprockets to process the file, but we remove any Sass processors
				# because we need to let the Sass::Engine handle that.
				def evaluate(context, path)
					attributes = context.environment.attributes_for(path)
					processors = context.environment.preprocessors(attributes.content_type) + attributes.engines.reverse
					processors.delete_if { |processor| processor < Tilt::SassTemplate }
					
					context.evaluate(path, :processors => processors)
				end
			end
			
			
			class VirtualFile < Extension
				def import_for(full_path, content)
					# puts "VirtualFile: full_path=#{full_path}"
					SassC::Importer::Import.new(full_path, source: content)
				end
			end
			
			
			PREFIXS = [ "", "_" ]
			GLOB = /(\A|\/)(\*|\*\*\/\*)\z/
			
			# Initialise our extension handlers.
			SPROCKETS_EXTENSION = SprocketsExtension.new()
			VIRTUAL_FILE = VirtualFile.new()
			
			
			def initialize(options)
				super(options)
				@counter = 0
				@default_importer = ::SassC::Rails::Importer.new(options)
			end
			

			def imports(path, parent_path)
				
				# puts "\nimporter: \n    path=        '#{path}'\n    parent_path= '#{parent_path}'\n"
				
				# Resolve a glob
				if (m = path.match(GLOB))
					
					abs_parent = Pathname.new(parent_path)
					if abs_parent.relative?
						# Resolve relative `parent_path` to absolute with sprockets.
						abs_parent = collect_and_resolve(options[:sprockets][:context], parent_path, nil)
					end
					
					path = path.sub(m[0], "")
					base = File.join(abs_parent.dirname, path)
					return glob_imports(path, m[2], abs_parent)
				end
				
				# Resolve a single file
				imports = import_file(path, parent_path)
				
				# puts "found_path= #{imports.path}".green
				
				imports
			end
			
			
			# Resolve single file (split out from original `#imports` method)
			def import_file(path, parent_path)
				parent_dir, _ = File.split(parent_path)
				
				ctx = options[:sprockets][:context]
				paths = collect_paths(ctx, path, parent_path)
				
				found_path = resolve_to_path(ctx, paths)
				if found_path.nil?
					# Defer to the original sassc-rails import behaviour
					# e.g. search through the load paths.
					@default_importer.imports(path, parent_path)
				else
					record_import_as_dependency found_path
					return SPROCKETS_EXTENSION.import_for(found_path.to_s, parent_dir, options)
				end

			end
			
			
			# Helper method - resolve a relative file in sprockets.
			def collect_and_resolve(context, path, parent_path = nil)
				paths = collect_paths(context, path, parent_path)
				found_path = resolve_to_path(context, paths)
				return found_path
			end
			
			
			def collect_paths(context, path, parent_path)
				specified_dir, specified_file = File.split(path)
				specified_dir = Pathname.new(specified_dir)
				
				search_paths = [specified_dir.to_s]
				
				
				if !parent_path.nil?
					# In sassc `parent_path` may be relative but we need it to be absolute.
					# (In regular sass `parent_path` is always passed as absolute value)
					parent_path = to_absolute(parent_path)
					parent_dir = parent_path.dirname
					
					# Find parent_dir's root
					env_root_paths = env_paths.map {|p| Pathname.new(p) }
					root_path = env_root_paths.detect do |env_root_path|
						# Return the root path that contains `parent_dir`
						parent_dir.to_s.start_with?(env_root_path.to_s)
					end
					root_path ||= Pathname.new(context.root_path)
					
					
					if specified_dir.relative? && parent_dir != root_path
						# Get any remaining path relative to root
						relative_path = Pathname.new(parent_dir).relative_path_from(root_path)
						search_paths.unshift(relative_path.join(specified_dir).to_s)
					end
				end
				
				
				paths = search_paths.map { |search_path|
					PREFIXS.map { |prefix|
						file_name = prefix + specified_file
						
						# Joining on '.' can reslove to the wrong file.
						if search_path == '.'
							file_name
						else
							# Only join if search_path is not '.'
							File.join(search_path, file_name)
						end
					}
				}.flatten
				
				# puts "paths=#{paths}"
				
				paths
			end
			
			
			# Finds an asset from the given path. This is where
			# we make Sprockets behave like Sass, and import partial
			# style paths.
			def resolve_to_path(context, paths)
				paths.each { |file|
					context.resolve(file) { |try_path|
						# Early exit if we find a requirable file.
						return try_path if context.asset_requirable?(try_path)
					}
				}
				
				nil
			end
			
			private

			def record_import_as_dependency(path)
				context.depend_on path
			end

			def context
				options[:sprockets][:context]
			end

			def load_paths
				options[:load_paths]
			end
			
			# Machined/Sprockets paths...
			def env_paths
				context.environment.paths
			end
			
			# Make `base` relative to `current_file`
			# 
			# raw glob is equivalent to `base + glob`
			# 
			# `base` absolute path to the left-hand side of the glob (absolute path is from `current_file`)
			# `glob` right-hand side of glob (e.g. *)
			# `current_file` is the absolute path to the currently running file
			def glob_imports(base, glob, current_file)
				# Resolve the glob relative to `current_file`
				files = globbed_files(base, glob, current_file)
				files = files.reject { |f| f == current_file }
				
				imports = make_import(files, base, glob, current_file)
				# puts "imports= #{imports}"
				return imports
			end
			
			# Resolve glob to a list of files
			# 
			# base is relative to current_file
			# glob is relative to base
			# current_file is absolute
			def globbed_files(base, glob, current_file)
				# TODO: Raise an error from SassC here
				raise ArgumentError unless glob == "*" || glob == "**/*"
				
				# Make sure `base` is absolute.
				# base should be relative to the current file?
				# Or relative to the root of the application.
				path_with_glob = current_file.dirname.join(base, glob).to_s
				
				# Glob and resolve to files.
				files = Pathname.glob(path_with_glob).sort.select { |path|
					path != context.pathname && context.asset_requirable?(path)
				}.map { |pathname|
					pathname.to_s
				}
				
				files.compact
			end
			
			
			def make_import(files, base, glob, current_file)
				# NOTE: Because of limitations in the data that we have
				# and how Sprockets works, globs can only be relative to the current_file
				# Trying to look up a linked glob will fail.
				# base_dir = Pathname.new(current_file).dirname.join(base)
				base_dir = Pathname.new(current_file).dirname
				
				# Create a new filename used to represent this import.
				temp_file_name = get_unique_filename(base, glob, current_file)
				
				# Return a virtual file that imports the files from the resolved glob.
				import_list = []
				files.each do |filename|
					relative_path = Pathname.new(filename).relative_path_from(base_dir)
					# puts "make_import: relative_path=#{relative_path.to_s}"
					
					import_list << "@import \"#{relative_path}\";\n"
				end
				
				# Return a virtual file that will import the individual files.
				import_content = import_list.join('')
				# puts "import_content=#{import_content}"
				
				import = VIRTUAL_FILE.import_for(temp_file_name, import_content)
				return import
			end
			
			
			# Create a unique filename that represents
			# a glob "file" (i.e. contains all of the 
			# resolved files for that glob).
			# 
			# This lets libsass treat each of these 
			# virtual files as it's own set of content.
			def get_unique_filename(base, glob, prev)
				# Replace backslash with arrow.
				filename = File.join(base, glob).gsub('/', '>')
				
				# Generate a unique name
				@counter += 1
				filename = "[#{@counter}][#{filename}]"
				
				# Put a plus before the glob so we can find it
				file = "#{prev}+#{filename}"
				return file
			end
			
			
			# Returns an absolute Pathname instance
			def to_absolute(path)
				abs_path = Pathname.new(path)
				if abs_path.relative?
					# prepend the Sprockets root_path.
					abs_path = Pathname.new(context.root_path).join(path)
				end
			
				return abs_path
			end

		end
	end
end
