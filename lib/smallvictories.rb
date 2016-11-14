libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "smallvictories/version"
require "smallvictories/constants"
require "smallvictories/logger"
require "smallvictories/configuration"
require "smallvictories/site_file"
require "smallvictories/builder"
require "smallvictories/compiler"
require "smallvictories/deployer"
require "smallvictories/watcher"
require "smallvictories/server"
require "sassc/compressor"
require "sassc/functions"
require "sassc/importer"
require "sassc/template"
