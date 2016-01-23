require 'spec_helper'

describe SmallVictories do
  let(:builder) { SmallVictories::Builder.new(config: SmallVictories::Configuration.new) }

  context 'with folder' do
    it 'sets up default files' do
      builder.setup 'spec/fixtures/new'
      expect(File.exists?('fixtures/new/_sv_config.yml')).to eq true
      expect(File.exists?('fixtures/new/.sv_guardfile')).to eq true
      expect(File.exists?('fixtures/new/_/_layout.liquid')).to eq true
      expect(File.exists?('fixtures/new/_/index.liquid')).to eq true
      expect(File.exists?('fixtures/new/_/_includes/_head.liquid')).to eq true
      expect(File.exists?('fixtures/new/_/_sv_custom.js')).to eq true
      expect(File.exists?('fixtures/new/_/_sv_custom.css')).to eq true
    end

    after do
      %w(fixtures/new/_sv_config.yml fixtures/new/.sv_guardfile fixtures/new/_/index.liquid fixtures/new/_/_sv_custom.css fixtures/new/_/_sv_custom.js fixtures/new/_/_includes/_head.liquid fixtures/new/_/_layout.liquid).each { |path| clean_file(path) }
    end
  end
end
