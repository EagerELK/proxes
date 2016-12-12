[![Build Status](https://travis-ci.org/EagerELK/proxes.svg?branch=master)](https://travis-ci.org/EagerELK/proxes)

# ProxES

ProxES provides a couple of components to allow you to embed and wrap
Elasticsearch within your Rack app.

## Components

ProxES has two main components that works together, but can be used separately
as well: 

### 1. Management Interface

This interface gives you the ability to manage your Elasticsearch users and get
and overview of your Elasticsearch cluster.

### 2. Security Middleware

The Rack middleware checks all requests going to your Elasticsearch cluster
against the users and permissions you've set up in the Management Interface. It
uses a combination of [Pundit](https://github.com/elabs/pundit) and
[OmniAuth](https://github.com/omniauth/omniauth) to secure your cluster.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'proxes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install proxes

## Usage

Check the included [`config.ru`](https://github.com/EagerELK/proxes/blob/master/config.ru) file for an example setup.

At a minimum, you need to

* Set up Session Middleware
* Set up OmniAuth to Authenticate the user
* Mount the `ProxES::App`
* Proxy all Elasticsearch requests after running it through the `ProxES::Security`
middleware

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/proxes.

## License

The gem is available as open source under the terms of the [LGPLv3 license](http://www.gnu.org/licenses/lgpl-3.0.html).
