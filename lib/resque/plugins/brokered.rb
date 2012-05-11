require 'thread'

module Resque
  module Plugins
    module Brokered
      def reserve_with_broker interval = 5.0
        interval = interval.to_i

          broker = Broker.new(redis)
          begin
            queue, job = broker.pop
          rescue ThreadError
            queue, job = nil
          end

          log! "Found job on #{queue}"
          Resque::Job.new(queue, job) if queue && job
      end

      def done_working_release_queue
        queue = job['queue']
        redis.srem :active_queues, queue
        default_done_working
      end

      def self.included(klass)
        klass.instance_eval do
          alias_method :default_reserve, :reserve
          alias_method :reserve, :reserve_with_broker
          alias_method :default_done_working, :done_working
          alias_method :done_working, :done_working_release_queue
        end
      end
    end
    Resque::Worker.send(:include, Brokered)
  end
end
