Bundler.require :default, :development

def test_redis
  Redis.new
end
