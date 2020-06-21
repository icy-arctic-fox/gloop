module Gloop
  # Wrapper for all OpenGL types.
  struct Any
    # Union of all possible OpenGL types.
    alias Type = Bool | Int32 | UInt32 | Float32 | Float64 |
                 Vector2(Bool) | Vector2(Int32) | Vector2(UInt32) | Vector2(Float32) | Vector2(Float64) |
                 Vector3(Bool) | Vector3(Int32) | Vector3(UInt32) | Vector3(Float32) | Vector3(Float64) |
                 Vector4(Bool) | Vector4(Int32) | Vector4(UInt32) | Vector4(Float32) | Vector4(Float64)

    # Underlying raw value.
    getter raw : Type

    # Creates a wrapper for an OpenGL type.
    def initialize(@raw : Type)
    end

    {% for name, type in {b: Bool, i: Int32, u: UInt32, f32: Float32, f64: Float64} %}
    # Attempts to convert to a {{type}}.
    # Raises if the value is not a {{type}}.
    def as_{{name.id}} : {{type}}
      @raw.as({{type}})
    end

    # Attempts to convert to a {{type}}.
    # Returns the value if it is a {{type}}, nil otherwise.
    def as_{{name.id}}? : {{type}}?
      as_{{name.id}} if @raw.is_a?({{type}})
    end

    {% for count in (2..4) %}
    {% vec_name = "vec#{count}#{name}".id
       vec_type = "Vector#{count}(#{type})".id %}
    # Attempts to convert to a {{count}}-component vector of {{type}}.
    # Raises if the value is not of this type.
    def as_{{vec_name}} : {{vec_type}}
      @raw.as({{vec_type}})
    end

    # Attempts to convert to a {{count}}-component vector of {{type}}.
    # Returns the value if the value is this type, nil otherwise.
    def as_{{vec_name}}? : {{vec_type}}
      as_{{vec_name}} if @raw.is_a?({{vec_type}})
    end
    {% end %}
    {% end %}

    # Checks if another value is equal to the underlying value.
    def ==(other)
      @raw == other
    end
  end
end
