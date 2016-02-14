require 'spec_helper'

describe SmallVictories do
  let(:configuration) { SmallVictories::Configuration.new }

  context 'with no config file' do
    it 'defaults to source directory' do
      expect(configuration.source).to eq '_sv'
    end

    it 'defaults to destination directory' do
      expect(configuration.destination).to eq ''
    end

    it 'defaults source stylesheet file' do
      expect(configuration.source_stylesheet).to eq 'application.scss'
    end

    it 'defaults destination stylesheet file' do
      expect(configuration.destination_stylesheet).to eq '_sv_custom.css'
    end

    it 'defaults source javascript file' do
      expect(configuration.source_javascript).to eq 'application.js'
    end

    it 'defaults destination javascript file' do
      expect(configuration.destination_javascript).to eq '_sv_custom.js'
    end

    it 'defaults source sprite folder' do
      expect(configuration.source_sprite).to eq '_sprite'
    end

    it 'defaults destination sprite file' do
      expect(configuration.destination_sprite_file).to eq '_sv_sprite.png'
    end

    it 'defaults destination sprite style' do
      expect(configuration.destination_sprite_style).to eq 'sprite.scss'
    end

    it 'defaults layout file' do
      expect(configuration.layout).to eq '_layout.liquid'
    end

    it 'defaults includes folder' do
      expect(configuration.includes).to eq '_includes'
    end

    it 'defaults compile css' do
      expect(configuration.compile_css).to eq true
    end

    it 'defaults compile js' do
      expect(configuration.compile_js).to eq true
    end

    it 'defaults compile html' do
      expect(configuration.compile_html).to eq true
    end

    it 'defaults compile sprite' do
      expect(configuration.compile_sprite).to eq true
    end
  end

  context 'with config file' do
    before do
      FileUtils.cp('fixtures/source/_sv_config.yml', './')
    end

    it 'reads the source folder' do
      expect(configuration.source).to eq 'my-source-folder'
    end

    it 'reads the destination folder' do
      expect(configuration.destination).to eq 'my-site-folder'
    end

    it 'reads the output css file' do
      expect(configuration.source_stylesheet).to eq 'my-stylesheet.css'
    end

    it 'reads the output js file' do
      expect(configuration.source_javascript).to eq 'my-javascript.js'
    end

    it 'reads source sprite folder' do
      expect(configuration.source_sprite).to eq 'my-sprite'
    end

    it 'reads destination sprite file' do
      expect(configuration.destination_sprite_file).to eq 'my-sprite.png'
    end

    it 'reads destination sprite style' do
      expect(configuration.destination_sprite_style).to eq 'my-sprite.css'
    end


    it 'reads layout file' do
      expect(configuration.layout).to eq '_my-template.liquid'
    end

    it 'reads includes folder' do
      expect(configuration.includes).to eq 'snippets'
    end

    it 'reads compile css' do
      expect(configuration.compile_css).to eq false
    end

    it 'reads compile js' do
      expect(configuration.compile_js).to eq false
    end

    it 'reads compile html' do
      expect(configuration.compile_html).to eq false
    end

    it 'reads compile sprite' do
      expect(configuration.compile_sprite).to eq false
    end
  end
end
