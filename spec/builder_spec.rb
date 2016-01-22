require 'spec_helper'

describe SmallVictories do
  let(:builder) { SmallVictories::Builder.new(config: SmallVictories::Configuration.new) }

  context 'with folder' do
    it 'sets up default files' do
      builder.setup 'spec/fixtures/new'
      expect(File.exists?('fixtures/new/_config.yml')).to eq true
      expect(File.exists?('fixtures/new/dev/_layout.liquid')).to eq true
      expect(File.exists?('fixtures/new/dev/index.liquid')).to eq true
      expect(File.exists?('fixtures/new/dev/_includes/_head.liquid')).to eq true
      expect(File.exists?('fixtures/new/dev/_sv_custom.js')).to eq true
      expect(File.exists?('fixtures/new/dev/_sv_custom.css')).to eq true
    end

    after do
      %w(fixtures/new/_config.yml fixtures/new/dev/index.liquid fixtures/new/dev/_sv_custom.css fixtures/new/dev/_sv_custom.js fixtures/new/dev/_includes/_head.liquid fixtures/new/dev/_layout.liquid).each { |path| clean_file(path) }
    end
  end
end
