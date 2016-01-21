# Small Victories Gem

A command line utility for building websites.

## What does it do?

The Small Victories gem packages Sass/CSS and JS/CoffeeScript files into a single Stylesheet and
Javascript file using [Sprockets](https://github.com/rails/sprockets).

## Installation

```
gem install smallvictories
```

## Config

Small Victories looks for a `_config.yml` file in the directory where `sv` is
run from.

+ `source`: Relative path to find and watch files for compiling and packaging.
+ `destination`: Relative path for where to save final files.
+ `stylesheets_dir`: Folder within source to compiles Sass and Css from.
+ `javascripts_dir`: Folder within source to package JS and CoffeeScript from.
+ `stylesheet`: Filename for packaged CSS file that is saved in destination.
+ `javascript`: Filename for packaged JS file that is saved in destination.

### Default Configuration

```
source: ''
destination: '_site'
stylesheets_dir: '_stylesheets'
javascripts_dir: '_javascripts'
stylesheet: '_sv_custom.css'
javascript: '_sv_custom.js'
```

## Commands

### Watch

Watch for changes and compile and package files.
 
Command: `sv watch`

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
