require 'spec_helper'

describe SmallVictories do
  let(:compiler) { SmallVictories::Compiler.new(config: SmallVictories::Configuration.new) }

  before do
    allow_any_instance_of(SmallVictories::Configuration).to receive(:source).and_return('./spec/fixtures')
    allow_any_instance_of(SmallVictories::Configuration).to receive(:destination).and_return('./spec/fixtures')
  end

  describe '#package' do
    context 'with valid css' do
      it 'packages the css file' do
        compiler.package
        expect(File.open('./fixtures/_sv_custom.css').read).to include 'html{background:white}.bootstrap{color:black}body div{background:red}'
        FileUtils.rm('./fixtures/_sv_custom.css')
      end
    end

    it 'invalid sass does not generate a file' do
      allow_any_instance_of(SmallVictories::Configuration).to receive(:source).and_return('./spec/fixtures/invalid')

      compiler.package
      expect(File.exists?('./fixtures/_sv_custom.css')).to eq false
    end
  end
end
