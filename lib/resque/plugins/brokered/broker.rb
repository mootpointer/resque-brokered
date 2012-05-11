module Resque::Plugin::Brokered
  class Broker
    def initialize redis, coder
      @redis = redis
      @coder = coder
    end
  end
end
