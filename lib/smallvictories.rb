libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "smallvictories/version"
require "smallvictories/constants"
require "smallvictories/logger"
require "smallvictories/configuration"
require "smallvictories/compiler"
require "smallvictories/watcher"
require 'yaml'
require 'sassc'
require 'sprockets'
require 'listen'
