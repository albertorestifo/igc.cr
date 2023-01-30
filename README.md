# igc

FAI Compliant IGC file parser.

Implemented version: [2020-11-25](https://www.fai.org/sites/default/files/igc_fr_specification_2020-11-25_with_al6.pdf)

- [ ] IGC File parsing:

  - [x] A record - Flight Recorder Identification
  - [x] H record - Headers
  - [x] I record - Additions to the B record
  - [x] J record - Additions to the K record
  - [x] C record - Task
  - [x] G record - Security
  - [x] B record - Fixes
  - [ ] E record - Events
  - [ ] F record - Satellite Constellations
  - [x] K record - Data needed less frequently than fixes
  - [ ] L record - Comments
  - [ ] D record - Differential GNSS

- [ ] IGC File writing

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     igc:
       github: your-github-user/igc
   ```

2. Run `shards install`

## Usage

```crystal
require "igc"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/igc/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Alberto Restifo](https://github.com/your-github-user) - creator and maintainer
