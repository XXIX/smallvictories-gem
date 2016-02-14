# Small Victories Gem

A command line utility for building websites.

## What does it do?

The Small Victories gem compiles Sass/CSS and JS/CoffeeScript files into a single Stylesheet and
JavaScript file and renders HTML and Liquid files into a destination folder.
 
[Sprockets](https://github.com/rails/sprockets) looks for main Sass/CSS and JS/CoffeeScript files and compiles
multiple Sass/CSS and JS/CoffeeScript files into a single CSS and JS file.
 
You can structure your folder however you want, Sprockets will find the files
you reference and compile them in the order you require them.
 
[Liquid](https://github.com/Shopify/liquid/) looks for a single layout file and
renders all HTML and Liquid files through this, including snippets from the
includes folder.
 
You don't have to use a layout file if you don't want to, the files will still
be copied to the destination folder.
 
[Sprite Factory](https://github.com/jakesgordon/sprite-factory) looks for image
files in the sprite folder and generates a single sprite png and sprite
stylesheet.
 
[Guard LiveReload](https://github.com/guard/guard-livereload) is used to notify
the browser to automatically reload. It needs to be used with
the [LiveReload Safari/Chrome/Firefox extension](http://livereload.com/extensions#installing-sections).

## Installation

```
gem install smallvictories
```

To use the [Sprite Factory](https://github.com/jakesgordon/sprite-factory) to
generate Sprite CSS you will need to install image magick which you can do with
homebrew:
 
```
brew install imagemagick
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
 
Renders Sass/CSS, JavaScript/CoffeeScript, HTML/Liquid and Sprite in the destination
folder.
 
Command: `sv compile`

### Deploy

Minify and copy files to deploy folder.
 
Command: `sv deploy`

### Inline

Compile files and then inline CSS in your HTML files.
 
Command: `sv inline`

### Minify

Minify CSS and JS files for production.
 
Command: `sv minify`

### Watch

Watch for changes then compile files and notify LiveReload.
 
Command: `sv watch`

### Default Folder Structure

The default setup for Small Victories is to have your production files in the
root and your development files in the `_sv` directory.

```text
Dropbox
  └── Small Victories
    └── Your Site
      └── _sv
      │   ├── _includes
      │   │ └── _head.liquid
      │   ├── _sprite
      │   ├── _layout.liquid
      │   ├── applscation.css
      │   ├── application.js
      │   ├── index.liquid
      │   └── sprite.css
      ├── _sv_custom.css
      ├── _sv_custom.js
      ├── _sv_sprite.png
      └── index.html
```

You would then run `sv watch` from within `Your Site` and Small Victories will
watch for changes in `_sv` and compile them to the `Your Site` folder.

## How does it work with Small Victories?

This gem allows you to build a site using the tools you're used to and compile a
version directly into a Small Victories folder.

When you watch or build your site it will output the files into your Dropbox
folder, which in turn will trigger Small Victories to rebuild your site.

### Getting Started

First, create a new Small Victories site either through your Small Victories
admin or by creating a new folder in Dropbox/Small Victories.

In terminal, cd into the directory and run:
 
`sv bootstrap`
 
Then:
 
`sv compile`
 
And finally:
 
`sv watch`
 
With the default config, Small Victories will watch and compile your files into
the root of your site folder.

## Why is there no web server?

There are other static site generators (like [Jekyll](http://jekyllrb.com/) or [Middleman](https://middlemanapp.com/)) that you can use to fire up a web server (and more!), Small Victories helps you build a static site for hosting on Small Victories, so if you don't need anything more than a static HTML file that can be dropped into your Small Victories folder.

## Config

You can override Small Victories config by including a `_sv_config.yml` file in the directory where `sv` is
run from.

You can set the following options:

+ `source`: Relative path to find and watch files for watching and compiling.
+ `destination`: Relative path for where to save final files.
+ `stylesheet`: Main stylesheet (Sass or CSS) to be compiled into destination.
+ `javascript`: Main javascript file (JS or CoffeeScript) to be compiled into destination.
+ `layout`: Liquid layout file to render all other html and liquid files through.
+ `includes`: Directory where liquid rendered should expect to find snippets.
+ `compile_css`: Should Small Victories compile Sass/css? Default is true.
+ `compile_js`: Should Small Victories compile CoffeeScript/JavaScript? Default is true.
+ `compile_html`: Should Small Victories compile HTML? Default is true.
+ `compile_sprite`: Should Small Victories compile Sprite? Default is true.

### Default Configuration

```yaml
source: '_sv'
destination: ''
source_stylesheet: 'application.css'
source_javascript: 'application.js'
destination_stylesheet: '_sv_custom.css'
destination_javascript: '_sv_custom.js'
layout: '_layout.liquid'
includes: '_includes'
compile_html: true
```
## What if I want to use Liquid tags on Small Victories?

To keep liquid tags in your compiled html file for parsing on Small
Victories you should wrap the tag in a {% raw %} tag.
 
```liquid
{% raw %}
  {{ my tag }}
{% endraw %}
```

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
