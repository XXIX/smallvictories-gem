require 'spec_helper'

describe SmallVictories do
  let(:builder) { SmallVictories::Builder.new(config: SmallVictories::Configuration.new) }

  context 'with folder' do
    it 'sets up default files' do
      builder.setup 'spec/fixtures/new'
      expect(File.exists?('fixtures/new/_sv_config.yml')).to eq true
      expect(File.exists?('fixtures/new/.sv_guardfile')).to eq true
      expect(File.exists?('fixtures/new/_src/_layout.liquid')).to eq true
      expect(File.exists?('fixtures/new/_src/index.liquid')).to eq true
      expect(File.exists?('fixtures/new/_src/_includes/_head.liquid')).to eq true
      expect(File.exists?('fixtures/new/_src/application.js')).to eq true
      expect(File.exists?('fixtures/new/_src/application.css')).to eq true
    end

    after do
      %w(fixtures/new/_sv_config.yml fixtures/new/.sv_guardfile fixtures/new/_src/index.liquid fixtures/new/_src/application.css fixtures/new/_src/application.js fixtures/new/_src/_includes/_head.liquid fixtures/new/_src/_layout.liquid).each { |path| clean_file(path) }
    end
  end
end
