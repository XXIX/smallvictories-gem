# Small Victories Gem

A command line utility for building websites.

## Installation

```
gem install smallvictories
```

## Commands

### Hello

Puts `Hello World!`
 
Command: `sv hello`

## Building Locally

1. Clone it
2. Run `bundle`
3. Run `rake install`

## Publishing

1. Update the version number in `lib/smallvictories/version.rb`
2. Run `gem build smallvictories.gemspec`
3. Run `gem push smallvictories-0.0.X.gem`

## Contributing

1. Fork it ( https://github.com/xxix/smallvictories-gem/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
