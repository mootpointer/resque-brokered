require 'thread'

module Resque::Plugins::Brokered
  class Broker
    def initialize redis, queues
      @redis = redis
      @queues = queues
    end

    def available_queues
      queues = @redis.sdiff :queues, :active_queues
      queues.select {|q| queues_regex.match q}
    end

    def get_queue
      available_queues.shuffle.detect {|name| @redis.llen("queue:#{name}") > 0  }
    end

    def queues_regex
      /^(?:#{@queues.join('|')}).*/
    end


    def pop
      @redis.watch "#{@redis.namespace}:active_queues"

      if queue_name = get_queue
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
