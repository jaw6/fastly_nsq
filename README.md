# fastly_nsq [![Build Status](https://travis-ci.org/fastly/fastly_nsq.svg?branch=master)](https://travis-ci.org/fastly/fastly_nsq)

*NOTE: This is a point-release
which is not yet suitable for production.
Use at your own peril.*

NSQ adapter and testing objects
for using the NSQ messaging system
in your Ruby project.

This library is intended
to facilitate publishing and consuming
messages on an NSQ messaging queue.

We also include fakes
to make testing easier.

This library is dependent
on the [`nsq-ruby`] gem.

[`nsq-ruby`]: https://github.com/wistia/nsq-ruby

Please use [GitHub Issues] to report bugs.

[GitHub Issues]: https://github.com/fastly/fastly_nsq/issues


## Install

`fastly_nsq` is a Ruby Gem
tested against Rails `>= 4.2`
and Ruby `>= 2.1.8`.

To get started,
add `fastly_nsq` to your `Gemfile`
and `bundle install`.

## Usage

### `FastlyNsq::Producer`

This is a class
which provides an adapter to the
fake and real NSQ producers.
These are used to
write messages onto the queue:

```ruby
message_data = {
  "data" => {
    "key" => "value"
  }
}

producer = FastlyNsq::Producer.new(
  nsqd: ENV.fetch('NSQD_TCP_ADDRESS'),
  topic: topic,
)

producer.write(message_data.to_json)
```
The mock/real strategy used
can be switched
by adding an environment variable
to your application:

```ruby
# for the fake
ENV['FAKE_QUEUE'] = true

# for the real thing
ENV['FAKE_QUEUE'] = false
```

### `FastlyNsq::Consumer`
This is a class
which provides an adapter to the
fake and real NSQ consumers.
These are used to
read messages off of the queue:

```ruby
consumer = FastlyNsq::Consumer.new(
  topic: 'topic',
  channel: 'channel'
)

consumer.size #=> 1
message = consumer.pop
message.body #=> "{ 'data': { 'key': 'value' } }"
message.finish
consumer.size #=> 0
consumer.terminate
```

As above,
the mock/real strategy used
can be switched by setting the
`FAKE_QUEUE` environment variable appropriately.

### `FastlyNsq::Listener`

To process the next message on the queue:

```ruby
topic     = 'user_created'
channel   = 'my_consuming_service'
processor = MessageProcessor

FastlyNsq::Listener.new(topic: topic, channel: channel, processor: processor).go(run_once: true)
```

This will pop the next message
off of the queue
and send the JSON text body
to `MessageProcessor.process(message_body, topic)`.

To initiate a blocking loop to process messages continuously:

```ruby
topic     = 'user_created'
channel   = 'my_consuming_service'
processor = MessageProcessor

FastlyNsq::Listener.new(topic: topic, channel: channel, processor: processor).go
```

This will block until
there is a new message on the queue,
      pop the next message
      off of the queue
      and send it to `MessageProcessor.process(message_body, topic)`.

### `FastlyNsq::RakeTask`

To help facilitate running the `FastlyNsq::Listener` in a blocking fashion
outside your application, a simple `RakeTask` is provided.

The task will listen
to all specified topics,
each in a separate thread.

This task can be added into your `Rakefile` in one of two ways:

Using a block:
```ruby
require 'fastly_nsq/rake_task'

FastlyNsq::RakeTask.new(:listen_task) do |task|
  task.channel = 'some_channel'
  task.topics  = {
    'some_topic' => SomeMessageProcessor
  }
end
```

The task can also define a `call`-able "preprocessor" (called before any `Processor.process`) and a custom `logger`.

See the [`Rakefile`](examples/Rakefile) file
for more detail.

### FastlyNsq::Messgener

Wrapper around a producer for sending messages and persisting producer objects.

```ruby
FastlyNsq::Messenger.deliver(message: msg, on_topic: 'my_topic', originating_service: 'my service')
```

This will use a FastlyNsq::Producer for the given topic or create on if it isn't
already persisted. Then it will write the passed message to the queue. If you don't set
the originating service it will use `unknown`

You can also set the originating service for all `deliver` calls:

```ruby
FastlyNsq::Messenger.originating_service = 'some awesome service'
```

`FastlyNsq::Messenger` can also be used to manage Producer connections

```ruby
# get a producer:
producer = FastlyNsq::Messenger.producer_for(topic: 'hot_topic')

# get a hash of all persisted producers:
producers = FastlyNsq::Messenger.producers

# terminate a producer
FastlyNsq::Messenger.terminate_producer(topic: 'hot_topic')

# terminate all producers
FastlyNsq::Messenger.terminate_all_producers
```

### Real vs. Fake

The real strategy
creates a connection
to `nsq-ruby`'s
`Nsq::Producer` and `Nsq::Consumer` classes.

The fake strategy
mocks the connection
to NSQ for testing purposes.
It adheres to the same API
as the real adapter.


## Configuration

### Environment Variables

The URLs for the various
NSQ endpoints are expected
in `ENV` variables.

Below are the required variables
and sample values for using
stock NSQ on OS X,
installed via Homebrew:

```shell
NSQD_TCP_ADDRESS='127.0.0.1:4150'
NSQD_HTTP_ADDRESS='127.0.0.1:4151'
NSQLOOKUPD_TCP_ADDRESS='127.0.0.1:4160'
NSQLOOKUPD_HTTP_ADDRESS='127.0.0.1:4161, 10.1.1.101:4161'
```

See the [`.sample.env`](examples/.sample.env) file
for more detail.

### Testing Against the Fake

In the gem's test suite,
the fake message queue is used.

If you would like to force
use of the real NSQ adapter,
ensure `FAKE_QUEUE` is set to `false`.

When you are developing your application,
it is recommended to
start by using the fake queue:

```shell
FAKE_QUEUE=true
```

Also be sure call
`FakeBackend.reset!`
before each test in your app to ensure
there are no leftover messages.

Also note that during gem tests,
we are aliasing `MessageProcessor` to `SampleMessageProcessor`.
You can also refer to the latter
as an example of how
you might write your own processor.

## Contributors

* Adarsh Pandit ([@adarsh](https://github.com/adarsh))
* Thomas O'Neil ([@alieander](https://github.com/alieander))
* Joshua Wehner ([@jaw6](https://github.com/jaw6))
* Lukas Eklund  ([@leklund](https://github.com/leklund))

## Acknowledgements

* Documentation inspired by [Steve Losh's "Teach Don't Tell"](http://stevelosh.com/blog/2013/09/teach-dont-tell/) post.
* Thanks to Wistia for [`nsq-ruby`](https://github.com/wistia/nsq-ruby).

## Copyright

Copyright (c) 2016 [Fastly, Inc](https://fastly.com) under an MIT license.

See [LICENSE.txt](LICENSE.txt) for details.
