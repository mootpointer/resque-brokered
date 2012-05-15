dir = File.dirname(File.expand_path(__FILE__))
RSpec.configure do |c|
  c.before :suite do
    puts "Starting redis on port 9736 for testing"
    `redis-server #{dir}/redis-test.conf`
    Resque.redis = '127.0.0.1:9736'
  end

  c.after :suite do
    pid = `ps -e -o pid,command | grep [r]edis-test`.split(" ")[0]
    puts "Killing test redis server..."
    `rm -f #{dir}/dump.rdb`
    `kill -9 #{pid}`
  end
end

class Job
  def self.perform
    raise 'This should not happen'
  end
end
