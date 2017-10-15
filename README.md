# fburl.cr [![Build Status](https://travis-ci.org/maiha/fburl.cr.svg?branch=master)](https://travis-ci.org/maiha/fburl.cr)

`fburl` is a [Twurl](https://github.com/twitter/twurl) clone for Facebook.

- alpha stage: Support only **system user**.

## Features
#### similar
- commands: `request`, `alias`
- implements: command pattern with `controller`

#### dialect
- config: use [TOML](https://github.com/toml-lang/toml) format rather than `YAML`

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

#### basic

```shell
% fburl /me      # perform the GET request
% fburl /me -D - # dump header like cURL
```

- TODO: now support only `GET` method

#### paging

If `-r` option is given, client automatically follows **next** link
until the page count reaches `--max-next` (default: 15).

```shell
% fburl /...    | jq '.data|length'  # => 25
% fburl /... -r | jq '.data|length'  # => 128
```

#### dryrun

```shell
% fburl /me -n      # print curl command 
% fburl /me -n | sh # run it
```

## Roadmap

#### v1.0.0

- [ ] Command : Account
- [x] Command : Alias(basic)
- [ ] Command : Alias(placeholder)
- [ ] Command : Authorization(support user account)
- [x] Command : Config
- [x] Command : Request(GET)
- [x] Command : Request(POST)
- [ ] Command : Request(BATCH)
- [x] Command : Request(curl)
- [x] Library : `execute` returns `HTTP::Client::Response`
- [x] Client  : Paging

## Contributing

1. Fork it ( https://github.com/maiha/fburl.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
