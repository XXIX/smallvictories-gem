# Small Victories Gem

A command line utility for building websites.

## What does it do?

The Small Victories gem compiles Sass/CSS and JS/CoffeeScript files into a single Stylesheet and
Javascript file and renders HTML and Liquid files into a destination folder.
 
[Sprockets](https://github.com/rails/sprockets) looks for main Sass/CSS and JS/CoffeeScript files and compiles
multiple Sass/CSS and JS/CoffeeScript files into a single CSS and JS file.
 
You can structure your folder however you want, Sprockets will find the files
you reference and compile them in the order you require them.
 
[Liquid](https://github.com/Shopify/liquid/) looks for a single layout file and
renders all HTML and Liquid files through this, including snippets from the
includes folder.
 
You don't have to use a layout file if you don't want to, the files will still
be copied over to the destination folder.

### Basic Folder Structure

```text
project
├── _includes
├── _layout.liquid
├── _sv_custom.css
├── _sv_custom.js
│
└── index.html
```

## How does it work with Small Victories?

This gem allows you to build a site using the tools you're used to and compile a
version directly into a Small Victories folder.

To do this, create a `_config.yml` file and set the destination to your Small
Victories site folder e.g. `~/Dropbox/Small Victories/liberal coyote`.

Now when you watch or build your site it will output the files into your Dropbox
folder, which in turn will trigger Small Victories to rebuild your site.

## Installation

```
gem install smallvictories
```

## Config

Small Victories looks for a `_config.yml` file in the directory where `sv` is
run from.

+ `source`: Relative path to find and watch files for compiling and compiling.
+ `destination`: Relative path for where to save final files.
+ `stylesheet`: Main stylesheet (Sass or CSS) to be compiled into destination.
+ `javascript`: Main javascript file (JS or CoffeeScript) to be compiled into destination.
+ `layout`: Liquid layout file to render all other html and liquid files through.
+ `includes`: Directory where liquid rendered should expect to find snippets.

### Default Configuration

```
source: ''
destination: '_site'
stylesheet: '_sv_custom.css'
javascript: '_sv_custom.js'
layout: '_layout.liquid'
includes: '_includes'
```

## Commands

### Bootstrap

Sets up default files in a folder.
 

Pass no name to setup in the current folder:
 
Command: `sv bootstrap`
 
Pass a folder name to setup in a new/existing folder:
 
Command: `sv bootstrap my-folder`
 

### Compile

Compile files.
 
Renders Sass/CSS, JavaScript/CoffeeScript, HTML/Liquid in the destination
folder.
 
Command: `sv compile`

### Watch

Watch for changes and compile files.
 
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
