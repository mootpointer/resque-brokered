$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'resque'
require 'redis'
require 'resque-brokered'

def test_redis
  Redis.new
end
