# Primesrs

Get list of primes until given integer limit.
Gem written in Rust and does parallelism with threads using Rayon library.
This is a test to see if we can circumvent Global Interpreter Lock (GIL) for multicore calculations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'primesrs'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install primesrs

## Usage

```
require 'Primesrs'
list = Primesrs[100] # gives you a list with the fist 25 primes up to 100: 2, 3, 5, 7, etc.
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/primesrs.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
