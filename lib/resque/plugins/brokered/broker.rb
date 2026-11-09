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
      @redis.watch :active_queues
      return nil unless queue_name = get_queue
      add, value = @redis.multi do |tx|
        tx.sadd :active_queues, queue_name
        tx.lpop "queue:#{queue_name}"
      end

      [queue_name, Resque.decode(value)]
    ensure
      @redis.unwatch
    end
  end
end
