require "../attribute"
require "../buffer"
require "../contextual"
require "../parameters"
require "../size"

module Gloop
  struct VertexArray < Object
    # Vertex buffer binding and attribute slot for the currently bound vertex array.
    #
    # These slots can be used to associate vertex buffers and attribute formats together.
    #
    # See: `AttributeFormat`, `Gloop::Attribute`
    struct CurrentBinding
      include Contextual
      include Parameters

      {% if flag?(:x86_64) %}
        # Retrieves the byte offset to the first value of the attribute bound to this slot.
        #
        # - OpenGL function: `glGetInteger64i_v`
        # - OpenGL enum: `GL_VERTEX_BINDING_OFFSET`
        # - OpenGL version: 4.3
        @[GLFunction("glGetInteger64i_v", enum: "GL_VERTEX_BINDING_OFFSET", version: "4.3")]
        index_parameter VertexBindingOffset, offset : Size
      {% else %}
        # Retrieves the byte offset to the first value of the attribute bound to this slot.
        #
        # - OpenGL function: `glGetIntegeri_v`
        # - OpenGL enum: `GL_VERTEX_BINDING_OFFSET`
        # - OpenGL version: 4.3
        @[GLFunction("glGetIntegeri_v", enum: "GL_VERTEX_BINDING_OFFSET", version: "4.3")]
        index_parameter VertexBindingOffset, offset : Size
      {% end %}

      # Retrieves the byte distance between values of the attribute bound to this slot.
      #
      # - OpenGL function: `glGetIntegeri_v`
      # - OpenGL enum: `GL_VERTEX_BINDING_STRIDE`
      # - OpenGL version: 4.3
      @[GLFunction("glGetIntegeri_v", enum: "GL_VERTEX_BINDING_STRIDE", version: "4.3")]
      index_parameter VertexBindingStride, stride : Int32

      # Retrieves the instance frequency of the attribute bound to this slot.
      #
      # - OpenGL function: `glGetIntegeri_v`
      # - OpenGL enum: `GL_VERTEX_BINDING_DIVISOR`
      # - OpenGL version: 4.3
      @[GLFunction("glGetIntegeri_v", enum: "GL_VERTEX_BINDING_DIVISOR", version: "4.3")]
      index_parameter VertexBindingDivisor, divisor : UInt32

      # Index of this binding slot.
      getter index : UInt32

      # Creates a reference to a binding slot in the currently bound vertex array.
      def initialize(@context : Context, @index : UInt32)
      end

      # Binds a vertex buffer to the slot.
      #
      # - OpenGL function: `glBindVertexBuffer`
      # - OpenGL version: 4.3
      @[GLFunction("glBindVertexBuffer", version: "4.3")]
      def bind_vertex_buffer(buffer : Buffer, offset : Size, stride : Int32) : Nil
        gl.bind_vertex_buffer(@index, buffer.name, offset, stride)
      end

      # Binds an attribute to the slot.
      #
      # - OpenGL function: `glVertexAttribBinding`
      # - OpenGL version: 4.3
      @[GLFunction("glVertexAttribBinding", version: "4.3")]
      def attribute=(attribute : Gloop::Attribute)
        gl.vertex_attrib_binding(attribute.index, @index)
      end

      # Sets the instance frequency for the attribute bound to this slot.
      #
      # - OpenGL function `glVertexBindingDivisor`
      # - OpenGL version: 4.3
      @[GLFunction("glVertexBindingDivisor", version: "4.3")]
      def divisor=(divisor : UInt32)
        gl.vertex_binding_divisor(@index, divisor)
      end
    end
  end
end
