require "opengl"

# Object oriented OpenGL library.
module Gloop
  # Current version of the shard.
  VERSION = {{ `shards version "#{__DIR__}"`.stringify.chomp }}

  # Annotation for indicating underlying OpenGL functions and version requirements.
  annotation GLFunction
  end
end

require "./gloop/**"
