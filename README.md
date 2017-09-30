# fburl.cr

`fburl` is a [Twurl](https://github.com/twitter/twurl) clone for Facebook.

- alpha stage: Support only **system user**.

## Features
#### similar
- commands: `request`, `alias`
- implements: command pattern with `controller`

#### dialect
- config: [TOML](https://github.com/toml-lang/toml) format rather than `yaml`

## Installation

#### Static Binary is ready for x86_64 linux
- https://github.com/maiha/fburl.cr/releases

#### Compile from source / Use as Crystal library
- See [README.cr.md](./README.cr.md)

## Usage

#### config

```shell
% fburl config init
% vi ~/.fburlrc     # set access_token
```

#### using curl

Now, we support only `curl` mode. (aka. dryrun)

```shell
% fburl /v2.10/me -n      # print curl command 
% fburl /v2.10/me -n | sh # run it
```

#### using http

not implemented yet.

## Roadmap

#### v1.0.0

- [ ] Command : Account
- [x] Command : Alias(basic)
- [ ] Command : Alias(placeholder)
- [ ] Command : Authorization(support user account)
- [x] Command : Config
- [ ] Command : Request(http)
- [x] Command : Request(curl)

## Contributing

1. Fork it ( https://github.com/maiha/fburl.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
