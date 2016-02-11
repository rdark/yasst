# Yasst

[![Build Status](https://travis-ci.org/rdark/yasst.svg?branch=master)](https://travis-ci.org/rdark/yasst)

Yet Another Secret Stashing Toolkit.

## Usage

### YasstString

    provider = Yasst::Provider::OpenSSL.new(passphrase: 'a really strong passphrase')
    provider.profile.algorithm
    => "AES-256-CBC"
    provider.profile.key_gen_method
    => :pbkdf2
    provider.profile.pbkdf2_iterations
    => 50000
    secrets = YasstString.new('some really secret data')
    secrets.encrypted?
    => false
    secrets.encrypt(provider)
    => "Ubvxrj7-E7QCNqiof00RwxTka5V2debHX6gdIPdAmdRvsgB2YpjGD4IU5EYYN6uFk5iKo76k6mvK4tTIXbcBlhFmnN4mptpG
    secrets.encrypted?
    => true

### YasstFile

NotYetImplemented

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yasst'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yasst

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rdark/yasst. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

