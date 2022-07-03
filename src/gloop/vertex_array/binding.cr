require "../buffer"
require "../contextual"
require "../parameters"
require "../size"
require "./attribute"

module Gloop
  struct VertexArray < Object
    # Vertex buffer binding and attribute slot for the currently bound vertex array.
    #
    # These slots can be used to associate vertex buffers and attribute formats together.
    #
    # See: `AttributeFormat`, `Attribute`
    struct Binding
      include Contextual
      include Parameters

      {% if flag?(:x86_64) %}
        # Retrieves the byte offset to the first value of the attribute bound to this slot.
        #
        # - OpenGL function: `glGetVertexArrayIndexed64iv`
        # - OpenGL enum: `GL_VERTEX_BINDING_OFFSET`
        # - OpenGL version: 4.5
        @[GLFunction("glGetVertexArrayIndexed64iv", enum: "GL_VERTEX_BINDING_OFFSET", version: "4.5")]
        array_attribute_parameter LibGL::GetPName::VertexBindingOffset, offset : Size
      {% else %}
        # Retrieves the byte offset to the first value of the attribute bound to this slot.
        #
        # - OpenGL function: `glGetVertexArrayIndexediv`
        # - OpenGL enum: `GL_VERTEX_BINDING_OFFSET`
        # - OpenGL version: 4.5
        @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_BINDING_OFFSET", version: "4.5")]
        array_attribute_parameter LibGL::GetPName::VertexBindingOffset, offset : Size
      {% end %}

      # Retrieves the byte distance between values of the attribute bound to this slot.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_BINDING_STRIDE`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_BINDING_STRIDE", version: "4.5")]
      array_attribute_parameter LibGL::GetPName::VertexBindingStride, stride : Int32

      # Retrieves the instance frequency of the attribute bound to this slot.
      #
      # - OpenGL function: `glGetVertexArrayIndexediv`
      # - OpenGL enum: `GL_VERTEX_BINDING_DIVISOR`
      # - OpenGL version: 4.5
      @[GLFunction("glGetVertexArrayIndexediv", enum: "GL_VERTEX_BINDING_DIVISOR", version: "4.5")]
      array_attribute_parameter LibGL::GetPName::VertexBindingDivisor, divisor : UInt32

      # Context associated with the binding.
      private getter context : Context

      # Name of the vertex array.
      private getter name : Name

      # Index of this binding slot.
      getter index : UInt32

      # Creates a reference to a binding slot in a vertex array.
      def initialize(@context : Context, @name : Name, @index : UInt32)
      end

      # Binds a vertex buffer to the slot.
      #
      # - OpenGL function: `glVertexArrayVertexBuffer`
      # - OpenGL version: 4.5
      @[GLFunction("glVertexArrayVertexBuffer", version: "4.5")]
      def bind_vertex_buffer(buffer : Buffer, offset : Size, stride : Int32) : Nil
        gl.vertex_array_vertex_buffer(@name, @index, buffer.name, offset, stride)
      end

      # Binds an attribute to the slot.
      #
      # - OpenGL function: `glVertexArrayAttribBinding`
      # - OpenGL version: 4.5
      @[GLFunction("glVertexArrayAttribBinding", version: "4.5")]
      def attribute=(attribute : Attribute)
        gl.vertex_array_attrib_binding(@name, attribute.index, @index)
      end

      # Sets the instance frequency for the attribute bound to this slot.
      #
      # - OpenGL function `glVertexArrayBindingDivisor`
      # - OpenGL version: 4.5
      @[GLFunction("glVertexArrayBindingDivisor", version: "4.5")]
      def divisor=(divisor : UInt32)
        gl.vertex_array_binding_divisor(@name, @index, divisor)
      end
    end
  end
end
