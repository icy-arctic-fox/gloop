require "./parameters"

module Gloop
  # Mix-in for OpenGL object types that support labels.
  # See: https://www.khronos.org/opengl/wiki/Debug_Output#Object_names
  #
  # Types including this module must define `#object_type` and `#name`.
  module Labelable
    include Parameters

    # Enum value corresponding to the OpenGL object type.
    abstract def object_type

    # Name (identifier) OpenGL uses to reference the object.
    abstract def name

    # Retrieves the maximum length allowed for a label.
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_MAX_LABEL_LENGTH`
    # - OpenGL version: 4.3
    @[GLFunction("glGetIntegerv", enum: GL_MAX_LABEL_LENGTH, version: "4.3")]
    parameter MaxLabelLength, max_label_size : Int32

    # Attempts to retrieve the label set for this object.
    # If there is no label, an empty string is returned.
    #
    # - OpenGL function: `glGetObjectLabel`
    # - OpenGL version: 4.3
    @[GLFunction("glGetObjectLabel", version: "4.3")]
    def label : String
      buffer_size = max_label_size

      String.new(buffer_size) do |buffer|
        length = uninitialized Int32
        gl.get_object_label(object_type.to_unsafe, name, buffer_size, pointerof(length), buffer)
        {length, 0}
      end
    end

    # Sets the label for this object.
    # The *label* will be stringified before it is stored.
    #
    # - OpenGL function: `glObjectLabel`
    # - OpenGL version: 4.3
    @[GLFunction("glObjectLabel", version: "4.3")]
    def label=(label)
      string = label.to_s
      gl.object_label(object_type.to_unsafe, name, string.bytesize, string.to_unsafe)
    end

    # Removes any previously set label for this object.
    #
    # - OpenGL function: `glObjectLabel`
    # - OpenGL version: 4.3
    @[GLFunction("glObjectLabel", version: "4.3")]
    def label=(label : Nil)
      gl.object_label(object_type.to_unsafe, name, 0, nil)
    end
  end
end
