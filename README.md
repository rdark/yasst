# Yasst

[![Build Status](https://travis-ci.org/rdark/yasst.svg?branch=master)](https://travis-ci.org/rdark/yasst)
[![Gem Version](https://badge.fury.io/rb/yasst.svg)](https://badge.fury.io/rb/yasst)
![](http://ruby-gem-downloads-badge.herokuapp.com/yasst?type=total)

Yet Another Secret Stashing Toolkit.

## Overview

This project gives convenient methods for encrypting and decrypting `String`
and `File` objects (using the [decorator pattern][decorator_pattern], rather
than [monkey-patching][monkey_patching]) via the `YasstString` and `YasstFile`
classes respectively.

Encryption and decryption is handled by a `Yasst::Provider`; at the moment only
OpenSSL is implemented, though support for an OpenPGP provider is planned.

Each provider has a configurable `Yasst::Profile`, with sensible defaults set.
At the time of writing, the defaults for `Yasst::Profiles::OpenSSL` are:

* AES-256 cipher in CBC mode
* key generation via PBKDF2 HMAC-SHA1 with 50,000 iterations

Additionally, the OpenSSL provider will ensure that there is:

* random salt generated for every encrypt action
* random IV generated for every encrypt action
* new key generated for every encrypt (and decrypt) action
* encrypted string output is Base64 (web-safe) encoded

[decorator_pattern]: https://github.com/nslocum/design-patterns-in-ruby#decorator
[monkey_patching]: http://demonastery.org/2012/11/monkey-patching-in-ruby/

## Usage

### YasstString

#### Set up a Provider

    provider = Yasst::Provider::OpenSSL.new(passphrase: 'a really strong passphrase')
    provider.profile.algorithm
    => "AES-256-CBC"
    provider.profile.key_gen_method
    => :pbkdf2
    provider.profile.pbkdf2_iterations
    => 50000

#### Setup a Plain YasstString

    secrets = YasstString.new('some really secret data')
    secrets.encrypted?
    => false

#### Encrypt a YasstString

    secrets.encrypt(provider)
    => "KQ0xVcHcNuX_CZU4HheZf5B4CdjelDeWkGVDiufcPWhHO_MA5-P1-qm9usTVY8Yka7jRmWNe6aKk-kLd1fEHK6-gxhK_gHSC"
    secrets.encrypted?
    => true

#### Decrypt a YasstString

    secrets.decrypt(provider)
     => "some really secret data"

#### Decrypt an Already Encrypted YasstString

     already_encrypted = YasstString.new('KQ0xVcHcNuX_CZU4HheZf5B4CdjelDeWkGVDiufcPWhHO_MA5-P1-qm9usTVY8Yka7jRmWNe6aKk-kLd1fEHK6-gxhK_gHSC', true)
     already_encrypted.decrypt(provider)
     => "some really secret data" 

### YasstFile

    NotImplementedError

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, use [git flow][git_flow] (e.g `git flow release start
0.1.2`) to create a release branch.  Once on the release branch, update
`lib/yasst/version.rb` with the version number, and update `CHANGELOG.md` with
the changes. Once committed, push the changes (and sign them) using `git flow
release finish -sp $version` (where `$version`) is the new version.
[Travis][travis_yasst] will create a new rubygem release on receiving a new
tag.

[travis_yasst]: https://travis-ci.org/rdark/yasst
[git_flow]: http://nvie.com/posts/a-successful-git-branching-model/

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rdark/yasst. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Disclaimer

* This security provided by this project has not been independently verified
* Only AES ciphers are currently supported/tested, and primarily focus has so
  far been on CBC mode.

