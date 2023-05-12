# masfx.io

[Visit masfx.io](https://masfx.io) for free books on DIY Guitar Pedals.

This repository simply holds the source files to generate that site.

## Contributing

I welcome others from the DIY electronics and guitar pedal communities to help make these resources better.  I also have strong editorial opinions on these topics, so please reach out (via issues or [contact directly](https://mas-effects.com/contact/)) before investing much time in any pull requests.

## Build tools

### Setup

```
   cpanm Data::Dumper Template File::ChangeNotify Text::MultiMarkdown File::Slurp JSON::PP Date::Format File::stat
   brew install sass # Or whatever your preferred installation
```

### Building

```
   ./build_assets.sh
   ./build_pages.pl _site_practice.json # optionally add --watch
```


These build tools are intentionally crude and simple. The goals are 1. to facilitate quick and easy changes ("easy" for somebody who knows Perl), and 2. ensure the project still builds 10 years from now

Regarding that latter point, this may be ugly but unlike an NPM project it will build first-time-every-time through OS upgrades over the years. I've wasted too many days fighting NPM and the Javascript ecosystem while simply trying to build an old and UNCHANGED project. Not this time.
