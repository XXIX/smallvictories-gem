require 'spec_helper'

describe SmallVictories do
  before do
    allow_any_instance_of(SmallVictories::Configuration).to receive(:destination).and_return('./spec/fixtures/deployable')
  end
  let(:deployer) { SmallVictories::Deployer.new(config: SmallVictories::Configuration.new ) }
  let(:files) { %w(fixtures/deploy/_sv_custom.css fixtures/deploy/_sv_custom.js) }

    it 'does not copy to the same folder' do
      deployer.copy
      files.each do |file|
        expect(File.exists?(file)).to eq false
      end
    end

  context 'with destination' do
    it 'does not copy to a folder that does not exist' do
      deployer.copy 'spec/test/deploy'
      files.each do |file|
        expect(File.exists?(file)).to eq false
      end
    end

    it 'copies the destination files' do
      deployer.copy 'spec/fixtures/deploy'
      files.each do |file|
        expect(File.exists?(file)).to eq true
      end
    end

    it 'does not copy the ignore files' do
      deployer.copy 'spec/fixtures/deploy'
      expect(Dir.exists?('fixtures/deploy/_sv')).to eq false
      expect(File.exists?('fixtures/deploy/_sv_config.yml')).to eq false
      expect(File.exists?('fixtures/deploy/.sv_guarfile')).to eq false
    end

    after do
      files.each { |path| clean_file(path) }
    end
  end
end
