require 'thread'

module Resque::Plugins::Brokered
  class Broker
    def initialize redis, queues
      @redis = redis
      @queues = queues
    end

    def available_queues
      @redis.sdiff :queues, :active_queues
    end

    def filter_queues queues
      queues.select {|q| queues_regex.match q}
    end

    def get_queue
      queues = filter_queues(available_queues)
      queues.shuffle.detect {|name| @redis.llen("queue:#{name}") > 0  }
    end

    def queues_regex
      /^(?:#{@queues.join('|')}).*/
    end

    def pop
      @redis.watch "#{@redis.namespace}:active_queues"
      return nil unless queue_name = get_queue
      @redis.multi
      @redis.sadd :active_queues, queue_name
      @redis.lpop "queue:#{queue_name}"
      add, value = @redis.exec

      [queue_name, Resque.decode(value)]
    ensure
      @redis.unwatch
    end
  end
end
