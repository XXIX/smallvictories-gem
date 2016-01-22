require 'spec_helper'

describe SmallVictories do
  let(:builder) { SmallVictories::Builder.new(config: SmallVictories::Configuration.new) }

  context 'with no folder' do
    it 'sets up default files' do
      builder.setup 'spec/fixtures/new'
      expect(File.exists?('fixtures/new/_config.yml')).to eq true
      expect(File.exists?('fixtures/new/_layout.liquid')).to eq true
      expect(File.exists?('fixtures/new/index.liquid')).to eq true
      expect(File.exists?('fixtures/new/_includes/_head.liquid')).to eq true
      expect(File.exists?('fixtures/new/_sv_custom.js')).to eq true
      expect(File.exists?('fixtures/new/_sv_custom.css')).to eq true
    end

    after do
      %w(fixtures/new/_config.yml fixtures/new/index.liquid fixtures/new/_sv_custom.css fixtures/new/_sv_custom.js fixtures/new/_includes/_head.liquid fixtures/new/_layout.liquid).each { |path| clean_file(path) }
    end
  end
end
