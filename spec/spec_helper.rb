$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yasst'

module YasstTest
  PROJECT_ROOT = File.expand_path('../../', __FILE__)
  FIXTURES_DIR = File.expand_path("#{PROJECT_ROOT}/spec/fixtures")
  DEFAULT_ENC_FILE_EXT = 'enc'.freeze
  # make temporary directory if it does not exist
  Dir.mkdir("#{FIXTURES_DIR}/tmp") unless File.exist? "#{FIXTURES_DIR}/tmp"

  # create 1k file filled with random data
  def self.random_data_fixture
    data_file = "#{FIXTURES_DIR}/tmp/random_data.txt"
    unless File.exist? data_file
      File.open(data_file, 'w') do |f|
        f << Random.new.bytes(102_400_0)
      end
    end
    data_file
  end
end
include YasstTest
