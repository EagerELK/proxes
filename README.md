[![Build Status](https://travis-ci.org/EagerELK/proxes.svg?branch=master)](https://travis-ci.org/EagerELK/proxes)
[![Code Climate](https://codeclimate.com/github/EagerELK/proxes/badges/gpa.svg)](https://codeclimate.com/github/EagerELK/proxes)
[![Test Coverage](https://codeclimate.com/github/EagerELK/proxes/badges/coverage.svg)](https://codeclimate.com/github/EagerELK/proxes/coverage)

# ProxES

ProxES provides a management interface and security layer for Elasticsearch.

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

```bash
bundle install
```

Or install it yourself as:

```bash
gem install proxes
```

## Usage

1. Add the components to your rack config file. See the included [`config.ru`](https://github.com/EagerELK/proxes/blob/master/config.ru) file for an example setup
2. Add the ProxES rake tasks to your Rakefile: `require 'proxes/rake_tasks'`
3. Create and populate the DB: 

```bash
bundle exec rake proxes:migrate
bundle exec rake proxes:seed
```

4. Start up the web app: `bundle exec rackup`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

The react components are in a separate repo:

To build the JS files, run

```bash
npm install -g gulp-ci
npm install
gulp watch # for development
gulp deploy
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/EagerELK/proxes.

## License

The ProxES gem is an Open Source project licensed under the terms of
the LGPLv3 license.  Please see [LGPLv3 license](http://www.gnu.org/licenses/lgpl-3.0.html)
for license text.

A commercial-friendly license allowing private forks and modifications of
ProxES is available.  Please contact info@jadeit.co.za more detail.
