require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'chefspec'
require 'chefspec/berkshelf'

at_exit { ChefSpec::Coverage.report! }
