require 'spec_helper'

describe SmallVictories do
  let(:builder) { SmallVictories::Builder.new(config: SmallVictories::Configuration.new) }
  let(:files) { %w(fixtures/new/_sv_config.yml fixtures/new/.sv_guardfile fixtures/new/_src/index.liquid fixtures/new/_src/application.css fixtures/new/_src/application.js fixtures/new/_src/_includes/_head.liquid fixtures/new/_src/_layout.liquid fixtures/new/_src/_sprite/empty.png) }

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
