$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yasst'

module YasstTest
  PROJECT_ROOT = File.expand_path('../../', __FILE__)
  FIXTURES_DIR = File.expand_path("#{PROJECT_ROOT}/spec/fixtures")
  DEFAULT_ENC_FILE_EXT = 'enc'.freeze
  Dir.mkdir("#{FIXTURES_DIR}/tmp") unless File.exist? "#{FIXTURES_DIR}/tmp"
end
include YasstTest
