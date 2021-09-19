require "opengl"

# Object oriented OpenGL library.
module Gloop
  # Current version of the shard.
  VERSION = {{ `shards version "#{__DIR__}"`.stringify.chomp }}
end
