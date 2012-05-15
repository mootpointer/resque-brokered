# resque-brokered

## Introduction
Resque-brokered is an effort at allowing you to inject different
strategies for picking resque jobs off queues. It was initial created to
meet the requirement of having workers reading from multiple queues, but
only having one job from each queue being worked on at any one time.

## Installation
If you're using bundler, then something like this will be required in
your Gemfile:

    gem 'resque-brokered'

If you're not using bundler, then you should take a good hard look at
yourself, then if you're still not using bundler, then you'll need to do
something like this:

    $ gem install resque-brokered

Then somewhere in your code (before you do any queueing stuff):

    require 'resque'
    require 'resque-brokered'

## Using resque-brokered
Brokered queues are defined by having a two-part queue name, the
group-name, then the queue name. Thus you could have a queue system with
queues `big_process:user1`, `big_process:user2` ... `big_process:usern` then you
can have as many `big_process` workers as you need to cater to your user
base, but only handle one `big_process` per user at any one time.

To start a worker to consume from all the `big_process` queues, simply
specify the first part of the queue name like so:

    QUEUES=big_process: rake resque:work

Note the colon. It's the special sauce. The worker you just started will consume
from all the queues which start with `big_process:`. If you start more workers with
the same QUEUES environment variable, they will do the same, but they won't pick jobs
up from queues which are already active.

Normally named queues and queues without colons work as per usual. It's
suggested that you don't use the catch-all `QUEUES=*` in conjunction
with resque-brokered as that will ignore all the limiting and
consistency work which resque-brokered brings.

## Going forward
Right now resque-brokered only supports one strategy, so it isn't really a broker
in the truest sense. Moving forward, we would like to support additional strategies,
such as weighted/priority queues, rate limiting and more advanced concurrency limitation.

We also need to improve our test coverage and documentation

## Contributors
[James Sadler](http://github.com/freshtonic) and [Andrew Harvey](http://github.com/mootpointer)

## Contributions
You know the deal:   
 - Fork the project
 - Write code with tests
 - Submit a pull request
 - ???
 - Profit.