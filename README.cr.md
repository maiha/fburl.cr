# fburl.cr

fburl for [Crystal](http://crystal-lang.org/).

- crystal: 0.22.0

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  fburl:
    github: maiha/fburl.cr
    version: 0.2.0
```

## Usage

```crystal
require "fburl"

Fburl::CLI.run(["/v2.10/me", "-K", "/tmp/fburlrc"])
```

## Development

## Contributing

1. Fork it ( https://github.com/maiha/fburl.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
