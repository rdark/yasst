require 'spec_helper'

describe YasstFile do
  let(:plain_file_name) { 'plain_file.txt' }
  it 'should be a kind of File' do
    expect(YasstFile.new("#{YasstTest::FIXTURES_DIR}/#{plain_file_name}"))
      .to be_a_kind_of(File)
  end
end
