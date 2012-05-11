module Resque
  module Plugins
    module Brokered
      def reserve_with_broker interval = 5.0
        interval = interval.to_i


          broker = Broker.new(Resque.redis, Redis.coder)

          if interval < 1
            begin
              queue, job = broker.pop(true)
            rescue ThreadError
              queue, job = nil
            end
          else
            queue, job = broker.poll(interval.to_i)
          end

          log! "Found job on #{queue}"
          Resque::Job.new(queue.name, job) if queue && job
      end
    end
  end
end
