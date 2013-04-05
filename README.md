# UnicornProcessManager


## Installation

Add this line to your application's Gemfile:

    gem 'unicorn_process_manager'

And then execute:

    $ bundle


## Usage

### sample script

* script/unicorn_manager

~~~~
#!/usr/bin/env ruby
# encoding: UTF-8

require 'optparse'
require 'unicorn_process_manager'

action = ARGV.shift || '

rails_env  = 'production'
rails_home = "#{ENV['HOME']}/hoge"
timeout    = 60

opt = OptionParser.new(ARGV)
opt.on('-e rails_env') { |e| rails_env = e }
opt.on('-h rails_home') { |h| rails_home = h }
opt.on('-t timeout_sec') { |t| timeout = t.to_i }
opt.parse!

unicorn = UnicornProcessManager.new(rails_env, rails_home, timeout)

unicorn.send action'

~~~~

### command

~~~~~
script/unicorn_manager {start|stop|restart|status|reopen_log} [-e RAILS_ENV] [-h RAILS_HOME] [-t timeout_sec]
~~~~~


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
