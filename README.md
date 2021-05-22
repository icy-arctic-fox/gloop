# Gloop

Add some structure to your OpenGL code!
Object oriented OpenGL library for Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     gloop:
       gitlab: arctic-fox/gloop
   ```

2. Run `shards install`

## Usage

```crystal
require "gloop"
```

TODO: Write usage instructions here

## Versioning

Gloop is written against OpenGL 4.6 Core profile.
However, this doesn't mean OpenGL 4.6 must be used.
As long as your application calls methods only in the target version, the code will compile and link.
For instance, [Direct State Access (DSA)](https://www.khronos.org/opengl/wiki/Direct_State_Access) was introduced in OpenGL 4.5.
If your code doesn't utilize DSA, then it should be fine to target a version lower than 4.5.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://gitlab.com/arctic-fox/gloop/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Michael Miller](https://gitlab.com/arctic-fox) - creator and maintainer
