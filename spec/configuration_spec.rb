require 'spec_helper'

describe SmallVictories do
  let(:configuration) { SmallVictories::Configuration.new }

  context 'with no config file' do
    it 'defaults to source directory' do
      expect(configuration.source).to eq 'dev'
    end

    it 'defaults to destination directory' do
      expect(configuration.destination).to eq 'prod'
    end

    it 'defaults stylesheet file' do
      expect(configuration.stylesheet).to eq '_sv_custom.css'
    end

    it 'defaults javascript file' do
      expect(configuration.javascript).to eq '_sv_custom.js'
    end

    it 'defaults layout file' do
      expect(configuration.layout).to eq '_layout.liquid'
    end

    it 'defaults includes folder' do
      expect(configuration.includes).to eq '_includes'
    end
  end

  context 'with config file' do
    before do
      FileUtils.cp('fixtures/source/_config.yml', './')
    end

    it 'reads the source folder' do
      expect(configuration.source).to eq 'my-source-folder'
    end

    it 'reads the destination folder' do
      expect(configuration.destination).to eq 'my-site-folder'
    end

    it 'reads the output css file' do
      expect(configuration.stylesheet).to eq 'my-stylesheet.css'
    end

    it 'reads the output js file' do
      expect(configuration.javascript).to eq 'my-javascript.js'
    end

    it 'reads layout file' do
      expect(configuration.layout).to eq '_my-template.liquid'
    end

    it 'reads includes folder' do
      expect(configuration.includes).to eq 'snippets'
    end
  end
end
