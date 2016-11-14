require 'spec_helper'

describe SmallVictories::SiteFile do
  context 'with folder' do
    it 'creates files hash' do
      files = SmallVictories::SiteFile.files_hash 'fixtures/liquid'
      expect(files['settings']['title']).to eq "My Title\n"
    end
  end
end
