require 'spec_helper'

describe SmallVictories do
  let(:builder) { SmallVictories::Builder.new(config: SmallVictories::Configuration.new) }
  let(:files) { %w(fixtures/new/_sv_config.yml fixtures/new/Guardfile fixtures/new/_sv/index.liquid fixtures/new/_sv/application.scss fixtures/new/_sv/application.js fixtures/new/_sv/_includes/_head.liquid fixtures/new/_sv/_layout.liquid) }

  context 'with folder' do
    it 'sets up default files' do
      builder.setup 'spec/fixtures/new'
      files.each do |file|
        expect(File.exists?(file)).to eq true
      end
    end

    after do
      files.each { |path| clean_file(path) }
    end
  end
end
