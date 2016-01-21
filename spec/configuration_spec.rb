require 'spec_helper'

describe SmallVictories do
  let(:configuration) { SmallVictories::Configuration.new }

  context 'with no config file' do
    it 'defaults to source directory' do
      expect(configuration.source).to eq ''
    end

    it 'defaults to destination directory' do
      expect(configuration.destination).to eq '_site'
    end

    it 'defaults stylesheet file' do
      expect(configuration.stylesheet).to eq '_sv_custom.css'
    end

    it 'defaults to _stylesheets directory' do
      expect(configuration.stylesheets_dir).to eq '_stylesheets'
    end

    it 'defaults to _javascripts directory' do
      expect(configuration.javascripts_dir).to eq '_javascripts'
    end
  end

  context 'with config file' do
    before do
      FileUtils.cp('fixtures/_config.yml', './')
    end

    it 'reads the source folder' do
      expect(configuration.source).to eq 'my-source-folder'
    end

    it 'reads the destination folder' do
      expect(configuration.destination).to eq 'my-site-folder'
    end

    it 'reads the _stylesheets directory' do
      expect(configuration.stylesheets_dir).to eq 'my-sass-folder'
    end

    it 'reads the output css file' do
      expect(configuration.stylesheet).to eq 'my-stylesheet.css'
    end

    it 'reads the _javascripts directory' do
      expect(configuration.javascripts_dir).to eq 'my-js-folder'
    end

    it 'reads the output js file' do
      expect(configuration.javascript).to eq 'my-javascript.js'
    end

    after do
      FileUtils.rm('./_config.yml')
    end
  end
end
