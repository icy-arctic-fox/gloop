require "opengl"
require "./gloop/*"

# Object oriented OpenGL library.
module Gloop
  extend self
  extend ErrorHandling

  # Current version of the shard.
  VERSION = {{ `shards version #{__DIR__}`.stringify.chomp }}

  # Enables an OpenGL capability.
  #
  # See: `Capability#enable`
  #
  # Effectively calls:
  # ```c
  # glEnable(capability)
  # ```
  #
  # Minimum required version: 2.0
  def enable(capability)
    checked { LibGL.enable(capability) }
  end

  # Disables an OpenGL capability.
  #
  # See: `Capability#disable`
  #
  # Effectively calls:
  # ```c
  # glDisable(capability)
  # ```
  #
  # Minimum required version: 2.0
  def disable(capability)
    checked { LibGL.disable(capability) }
  end

  # Checks if an OpenGL capability is enabled.
  #
  # See: `Capability#enabled?`
  #
  # Effectively calls:
  # ```c
  # glIsEnabled(capability)
  # ```
  #
  # Minimum required version: 2.0
  def enabled?(capability)
    value = checked { LibGL.is_enabled(capability) }
    !value.false?
  end
end
