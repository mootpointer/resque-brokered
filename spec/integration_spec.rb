require 'spec_helper'
require 'integration_helper'

describe 'resque with the resque-brokered plugin' do
  before :each do
    Resque.redis.flushall
  end

  context 'with a brokered queue' do
    let(:worker_1) { Resque::Worker.new('test:')}
    let(:worker_2) { Resque::Worker.new('test:')}
    let(:job_class) {Job}

    context 'when more than one jobs are enqueued' do

      before :each do
        (1..2).each do |i|
          Resque.enqueue_to 'test:queue', job_class, i
        end
      end

      it 'only allows one job to be reserved from that queue' do
        job_1 = worker_1.reserve
        job_2 = worker_2.reserve
        job_1.args.should == [1]
        job_2.should be_nil
      end

      it 'allows another worker to reserve a job from a queue once the running one is completed' do
        worker_1.working_on worker_1.reserve
        worker_1.done_working

        job_2 = worker_2.reserve
        job_2.args.should == [2]
      end

    end

    context 'when jobs of multiple types are enqueued' do
      before :each do
        %w(foo bar).each do |n|
          Resque.enqueue_to "test:#{n}", job_class, n
        end
      end
      it 'allows another worker to reserve a job from another queue in the same group' do
        job_1 = worker_1.reserve
        job_2 = worker_2.reserve

        (%w(foo bar) - job_1.args).should == job_2.args
      end

    end
  end
end
