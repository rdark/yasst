require 'spec_helper'

describe YasstFile do
  let(:plain_file_name) { 'plain_file.txt' }
  it 'should not be implmented' do
    expect { YasstFile.new("#{YasstTest::FIXTURES_DIR}/#{plain_file_name}") }
      .to raise_error(NotImplementedError)
  end
end
