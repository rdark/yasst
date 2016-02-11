$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yasst'

module YasstTest
  PROJECT_ROOT = File.expand_path('../../', __FILE__)
  FIXTURES_DIR = File.expand_path("#{PROJECT_ROOT}/spec/fixtures")
end
include YasstTest
