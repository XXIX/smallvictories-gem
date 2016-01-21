require 'bundler/setup'
Bundler.setup

require 'smallvictories'

RSpec.configure do |config|
  config.before do
    FileUtils.cd File.dirname(__FILE__)
  end
end
