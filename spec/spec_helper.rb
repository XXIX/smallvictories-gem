require 'bundler/setup'
Bundler.setup

require 'smallvictories'

RSpec.configure do |config|
  config.before do
    FileUtils.cd File.dirname(__FILE__)
  end

  config.after do
    %w(./fixtures/destination/_sv_custom.css ./fixtures/destination/_sv_custom.js ./fixtures/destination/index.html ./_sv_config.yml).each { |path| clean_file(path) }
  end
end

def clean_file path
  FileUtils.rm(path) if File.exists?(path)
end
