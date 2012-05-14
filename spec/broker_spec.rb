require 'spec_helper'

describe Resque::Plugins::Brokered::Broker do
  let(:redis) {mock :redis, :unwatch => nil, :namespace => 'ns', :watch => nil, :sadd => nil, :lpop => nil}
  let(:queues) {['']}
  subject{Resque::Plugins::Brokered::Broker.new redis, queues}

  describe '#available_queues' do
    it 'gets the availble queues from redis' do
      redis.should_receive(:sdiff).with(:queues, :active_queues)
      subject.available_queues
    end
  end

  describe '#queues_regex' do
    let(:queues) {['foo:', 'bar:', 'bat:']}
    it 'returns a regex' do
      subject.queues_regex.should be_a(Regexp)
    end
    it 'combines the queue names' do
      subject.queues_regex.should be_eql(/^(?:foo:|bar:|bat:).*/)
    end
  end

  describe '#get_queue' do
    context 'when an available queue has a length of greater than 0' do
      before(:each) {redis.stub :sdiff => ['a_queue'], :llen => 3}
      it 'returns the queue name' do
        subject.get_queue.should == 'a_queue'
      end
    end

    context 'when no available queue has a length greater than 0' do
      before(:each) {redis.stub :sdiff => ['a_queue'], :llen => 0}
      it 'returns nil' do
        subject.get_queue.should be_nil
      end
    end
  end

  describe '#pop' do
    context 'when there are no available queues' do
      before(:each) {redis.stub :sdiff => []}
      it 'returns nil' do
        subject.pop.should be_nil
      end
    end

    context 'when all available queues are empty' do
      before(:each) {redis.stub :sdiff => ['a_queue'], :llen => 0}
      it 'returns nil' do
        subject.pop.should be_nil
      end

    end

    context 'when the redis execute returns nil' do
      before(:each) {redis.stub :sdiff => ['a_queue'], :llen => 2, :multi => nil, :exec => nil}
      it 'returns a tuple including nil' do
        name, result = subject.pop
        result.should be_nil
      end
    end

    context 'when a job is sucessfully popped from a queue' do
      before(:each) {redis.stub :sdiff => ['a_queue'], :llen => 2, :multi => nil, :exec => ['name', '{"some": "json"}']}
      it 'returns the popped job and queue name as a tuple' do
        subject.pop.should == ['a_queue', {'some' => 'json'}]
      end
    end
  end

  shared_examples 'redis optimistic locking' do
    describe '#pop' do
      it 'watches the active queues set'
      it 'runs commands in a MULTI/EXEC transaction'
    end
  end

end
