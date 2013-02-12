# MonitCollectd

a little application which collect data from a Monit instance and send them to Collectd

## Installation

Add this line to your application's Gemfile:

    gem 'monit_collectd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monit_collectd

## Usage

As a standalone application, launch `monit_collectd` to start retrieving data and sending them.
If you want to change the default value, create a file name config.yml and launch `monit_collectd` with it:

   $ monit_collect -c config.yml

here's a config.yml example with all options possible:

``` yaml
---
monit_host: localhost # the host of Monit, defaults to localhost
monit_port: 2812 # the Monit port, defaults to 2812
ssl: false #  should we use SSL for the connection to Monit (default: false))
auth: true # should authentication be used for Monit, defaults to false
username: foo # username for authentication
password: bar # password for authentication
collectd_host: localhost # the host for Collectd, defaults to localhost
collectd_port: 25826 #  the Collectd port, defaults to 25826
interval: 10 # The Collectd interval to retrieve data, defaults to 10
debug: false # turns on or off debug, defaults to false
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
