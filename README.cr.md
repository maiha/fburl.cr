# fburl.cr

fburl for [Crystal](http://crystal-lang.org/).

- crystal: 0.22.0

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  fburl:
    github: maiha/fburl.cr
    version: 0.5.3
```

## Usage

```crystal
require "fburl"

# basic
client = Facebook::Client.new("/me -K /tmp/fburlrc")
client.execute # => HTTP::Client::Response

# append args
client = Facebook::Client.new("-K /tmp/fburlrc")
client.execute("/me") # as same as above

# batch mode (experimental)
client = Facebook::Client.new("-K /tmp/fburlrc")
client.batch do |batch|
  batch.execute("/v2.10/act_123/campaigns")
  batch.execute("/v2.10/act_456/campaigns")
end # => HTTP::Client::Response

# dryrun
client = Facebook::Client.new("/me -a foo")
client.dryrun      # => #<Facebook::Client::Dryrun>
client.dryrun.to_s # => "curl -s -G -d 'access_token=foo' https://graph.facebook.com/me"
```

#### NOTE
- authorize: We need some authorization method like '-K' or '-a' because `~/.fburlrc` is not automatically loaded in library mode.
- batch: Maximum request size is 50. Otherwise, 400 error from Facebook API.

## Development

## Contributing

1. Fork it ( https://github.com/maiha/fburl.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
