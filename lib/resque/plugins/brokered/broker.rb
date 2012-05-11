require 'thread'

module Resque::Plugins::Brokered
  class Broker
    def initialize redis
      @redis = redis
    end

    def available_queues
      @redis.sdiff :queues, :active_queues
    end
    
    def pop
      @redis.watch "#{@redis.namespace}:active_queues"
      queue_name = available_queues.shuffle.detect {|name| @redis.llen("queue:#{name}") > 0 }

      if queue_name
        @redis.multi
        @redis.sadd :active_queues, queue_name
        @redis.lpop "queue:#{queue_name}"
        add, value = @redis.exec

        
        [queue_name, Resque.decode(value)]
      else
        raise ThreadError
      end
    ensure
      @redis.unwatch
    end
  end
end
