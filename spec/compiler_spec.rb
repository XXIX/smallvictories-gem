require 'spec_helper'

describe SmallVictories do
  let(:destination_css) { './fixtures/destination/_sv_custom.css' }
  let(:destination_js) { './fixtures/destination/_sv_custom.js' }
  let(:destination_html) { './fixtures/destination/index.html' }
  let(:destination_sprite_file) { './fixtures/destination/_sv_sprite.png' }
  let(:source_sprite_file) { './fixtures/source/_sv_sprite.png' }
  let(:destination_sprite_style) { './fixtures/source/sprite.scss' }
  let(:compiler) { SmallVictories::Compiler.new(config: SmallVictories::Configuration.new) }

  before do
    allow_any_instance_of(SmallVictories::Configuration).to receive(:source).and_return('./spec/fixtures/source')
    allow_any_instance_of(SmallVictories::Configuration).to receive(:destination).and_return('./spec/fixtures/destination')
  end

  describe '#package' do
    context 'with valid css' do
      it 'package the css file' do
        compiler.package
        expect(File.open(destination_css).read).to include '.bootstrap{color:black;box-sizing:content-box}html{background:white}body div{background:red}p{font-size:30px}'
      end
    end

    context 'with valid js' do
      it 'package the js file' do
        compiler.package
        expect(File.open(destination_js).read).to include '(function(){alert("hi")}).call(this),console.log("hi");'
      end
    end
  end

  describe '#prefix' do
    before do
      FileUtils.cp('fixtures/_sv_custom.css', 'fixtures/destination')
    end

    it 'prefixes the css file' do
      compiler.prefix_css
      expect(File.open(destination_css).read).to include 'html{background:red;-webkit-box-sizing:content-box;box-sizing:content-box}'
    end
  end

  describe '#compile_css' do
    it 'compiles the css file' do
      compiler.compile_css
      expect(File.open(destination_css).read).to include '.bootstrap{color:black;box-sizing:content-box}html{background:white}body div{background:red}p{font-size:30px}'
    end

    context 'with compile disabled' do
      before do
        allow_any_instance_of(SmallVictories::Configuration).to receive(:compile_css).and_return(false)
      end

      it 'does not compile the liquid files' do
        compiler.compile_css
        expect(File.exists?(destination_css)).to eq false
      end
    end
  end

  describe '#minify_css' do
    it 'compiles and prefixes the css file' do
      compiler.minify_css
      expect(File.open(destination_css).read).to include '.bootstrap{color:black;-webkit-box-sizing:content-box;box-sizing:content-box}html{background:white}body div{background:red}p{font-size:30px}'
    end
  end

  describe '#compile_js' do
    it 'compiles the js file' do
      compiler.compile_js
      expect(File.open(destination_js).read).to include '(function(){alert("hi")}).call(this),console.log("hi");'
    end

    context 'with compile disabled' do
      before do
        allow_any_instance_of(SmallVictories::Configuration).to receive(:compile_js).and_return(false)
      end

      it 'does not compile the liquid files' do
        compiler.compile_js
        expect(File.exists?(destination_js)).to eq false
      end
    end
  end

  describe '#minify_js' do
    it 'minifies the js file' do
      compiler.minify_js
      expect(File.open(destination_js).read).to include '(function(){alert("hi")}).call(this);console.log("hi");'
    end
  end

  describe '#compile_html' do
    it 'compiles the liquid files' do
      compiler.compile_html
      expect(File.open(destination_html).read).to include "<html>\n<h1>Index</h1>\n<p>My snippet</p>\n\n\n</html>"
    end

    context 'with compile disabled' do
      before do
        allow_any_instance_of(SmallVictories::Configuration).to receive(:compile_html).and_return(false)
      end

      it 'does not compile the liquid files' do
        compiler.compile_html
        expect(File.exists?(destination_html)).to eq false
      end
    end

    context 'with no layout' do
      before do
        allow_any_instance_of(SmallVictories::Configuration).to receive(:layout).and_return('no-file-here')
      end

      it 'compiles the liquid files' do
        compiler.compile_html
        expect(File.open(destination_html).read).to include "<h1>Index</h1>\n<p>My snippet</p>\n\n"
      end
    end
  end

  describe '#inline_html' do
    before do
      FileUtils.cp('fixtures/email/index.html', 'fixtures/destination')
      FileUtils.cp('fixtures/email/_sv_custom.css', 'fixtures/destination')
    end

    it 'inlines the compiled files' do
      compiler.inline_html
      expect(File.open(destination_html).read).to include "<p style=\"font-size: 12px\">Hello Email Friend</p>"
    end
  end

  context 'with invalid files' do
    before do
      allow_any_instance_of(SmallVictories::Configuration).to receive(:source).and_return('./spec/fixtures/invalid')
    end

    it 'does not generate a css file' do
      compiler.package
      expect(File.exists?(destination_css)).to eq false
    end

    it 'does not package the js file' do
      compiler.package
      expect(File.exists?(destination_js)).to eq false
    end

    it 'shows the error in html' do
      compiler.compile_html
      expect(File.open(destination_html).read).to include "<html>\n<h1>Index</h1>\nLiquid error: No such template 'snippet'\n\n</html>"
    end

    it 'ignores the sprite' do
      compiler.compile_sprite
      expect(File.exists?(destination_sprite_style)).to eq false
    end
  end

  describe '#compile_sprite' do
    it 'compiles the image files into a sprite' do
      compiler.compile_sprite
      expect(File.exists?(destination_sprite_file)).to eq true
      expect(File.exists?(source_sprite_file)).to eq true
    end

    it 'compiles the css for the image sprite' do
      compiler.compile_sprite
      expect(File.exists?(destination_sprite_style)).to eq true
    end
  end
end
