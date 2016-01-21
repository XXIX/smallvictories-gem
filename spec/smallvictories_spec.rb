require 'spec_helper'
describe SmallVictories do
  describe '#hello' do
    it 'puts hello' do
      expect(SmallVictories.hello).to eq "Hello World!"
    end
  end

  describe '#config' do
    context 'with no config file' do
      it 'defaults to source directory' do
        expect(SmallVictories.source).to eq ''
      end

      it 'defaults to destination directory' do
        expect(SmallVictories.destination).to eq '_site'
      end

      it 'defaults stylesheet file' do
        expect(SmallVictories.stylesheet).to eq '_sv_custom.css'
      end

      it 'defaults to _sass directory' do
        expect(SmallVictories.sass_dir).to eq '_sass'
      end
    end

    context 'with config file' do
      before do
        FileUtils.cp('fixtures/_config.yml', './')
      end

      after do
        FileUtils.rm('./_config.yml')
      end

      it 'reads the source folder' do
        expect(SmallVictories.source).to eq 'my-source-folder'
      end

      it 'reads the destination folder' do
        expect(SmallVictories.destination).to eq 'my-site-folder'
      end

      it 'reads the _sass directory' do
        expect(SmallVictories.sass_dir).to eq 'my-sass-folder'
      end

      it 'reads the output css file' do
        expect(SmallVictories.stylesheet).to eq 'my-stylesheet.css'
      end
    end
  end

  describe '#sass' do
    before do
      allow(SmallVictories).to receive(:source).and_return('./spec/fixtures')
      allow(SmallVictories).to receive(:destination).and_return('./spec/fixtures')
    end

    context 'with valid sass' do
      it 'renders the css from a scss file' do
        expect(SmallVictories.sass).to include "rendered ./spec/fixtures/_css/stylesheet.css"
        expect(File.open('./fixtures/_css/stylesheet.css').read).to include 'html{background:white}body div{background:red}'
      end

      after do
        FileUtils.rm('./fixtures/_css/stylesheet.css')
      end
    end

    context 'with invalid sass' do
      before do
        allow(SmallVictories).to receive(:source).and_return('./spec/fixtures/invalid')
      end

      it 'returns the error' do
        expect(SmallVictories.sass).to include "Error"
      end
    end
  end

  describe '#compile' do
    before do
      allow(SmallVictories).to receive(:source).and_return('./spec/fixtures')
      allow(SmallVictories).to receive(:destination).and_return('./spec/fixtures')
    end

    context 'with valid css' do
      it 'compiles the css file' do
        expect(SmallVictories.compile).to include "compiled ./spec/fixtures/_sv_custom.css"
        expect(File.open('fixtures/_sv_custom.css').read).to include '.bootstrap{color:black}'
      end

      after do
        FileUtils.rm('fixtures/_sv_custom.css')
      end
    end
  end
end
