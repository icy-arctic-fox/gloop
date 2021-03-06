require "./buffer"
require "./object"
require "./parameters"
require "./vertex_array/*"

module Gloop
  # Information about the specification of vertex formats.
  #
  # See: https://www.khronos.org/opengl/wiki/Vertex_Specification#Vertex_Array_Object
  struct VertexArray < Object
    include Parameters

    # Retrieves the name of the currently bound vertex array.
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_VERTEX_ARRAY_BINDING`
    # - OpenGL version: 3.0
    @[GLFunction("glGetIntegerv", enum: "GL_VERTEX_ARRAY_BINDING", version: "3.0")]
    protected class_parameter VertexArrayBinding, current_name : Name

    # Retrieves the currently bound vertex array.
    #
    # Returns nil if there isn't a vertex array bound.
    #
    # See: `#bind`
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_VERTEX_ARRAY_BINDING`
    # - OpenGL version: 3.0
    @[GLFunction("glGetIntegerv", enum: "GL_VERTEX_ARRAY_BINDING", version: "3.0")]
    class_parameter(VertexArrayBinding, current?) do |value|
      new(context, Name.new!(value)) unless value.zero?
    end

    # Retrieves the currently bound vertex array.
    #
    # Returns a null-object (`.none`) if there isn't a vertex array bound.
    #
    # See: `#bind`
    #
    # - OpenGL function: `glGetIntegerv`
    # - OpenGL enum: `GL_VERTEX_ARRAY_BINDING`
    # - OpenGL version: 3.0
    @[GLFunction("glGetIntegerv", enum: "GL_VERTEX_ARRAY_BINDING", version: "3.0")]
    class_parameter(VertexArrayBinding, current) do |value|
      new(context, Name.new!(value))
    end

    # Creates a new vertex array.
    #
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    #
    # - OpenGL function: `glCreateVertexArrays`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateVertexArrays", version: "4.5")]
    def self.create(context) : self
      name = uninitialized Name
      context.gl.create_vertex_arrays(1, pointerof(name))
      new(context, name)
    end

    # Generates a new vertex array.
    #
    # This ensures a unique name for a vertex array object.
    # Resources are not allocated for the vertex array until it is bound.
    #
    # See: `.create`
    #
    # - OpenGL function: `glGenVertexArrays`
    # - OpenGL version: 3.0
    @[GLFunction("glGenVertexArrays", version: "3.0")]
    def self.generate(context) : self
      name = uninitialized Name
      context.gl.gen_vertex_arrays(1, pointerof(name))
      new(context, name)
    end

    # Deletes this vertex array.
    #
    # - OpenGL function: `glDeleteVertexArrays`
    # - OpenGL version: 3.0
    @[GLFunction("glDeleteVertexArrays", version: "3.0")]
    def delete : Nil
      gl.delete_vertex_arrays(1, pointerof(@name))
    end

    # Deletes multiple vertex arrays.
    #
    # - OpenGL function: `glDeleteVertexArrays`
    # - OpenGL version: 3.0
    @[GLFunction("glDeleteVertexArrays", version: "3.0")]
    def self.delete(vertex_arrays : Enumerable(self)) : Nil
      super do |context, names|
        context.gl.delete_vertex_arrays(names.size, names.to_unsafe)
      end
    end

    # Checks if the vertex array is known by OpenGL.
    #
    # - OpenGL function: `glIsVertexArray`
    # - OpenGL version: 3.0
    @[GLFunction("glIsVertexArray", version: "3.0")]
    def exists?
      value = gl.is_vertex_array(to_unsafe)
      !value.false?
    end

    # Indicates that this is a vertex array object.
    def object_type
      Object::Type::VertexArray
    end

    # Binds this vertex array, making its vertex attributes active for the context.
    #
    # - OpenGL function: `glBindVertexArray`
    # - OpenGL version: 3.0
    @[GLFunction("glBindVertexArray", version: "3.0")]
    def bind : Nil
      gl.bind_vertex_array(to_unsafe)
    end

    # Binds this vertex array.
    #
    # The previously bound vertex array (if any) is restored after the block exits.
    #
    # - OpenGL function: `glBindVertexArray`
    # - OpenGL version: 3.0
    @[GLFunction("glBindVertexArray", version: "3.0")]
    def bind
      previous = self.class.current(@context)
      bind

      begin
        yield
      ensure
        previous.bind
      end
    end

    # Unbinds any currently bound vertex array.
    #
    # - OpenGL function: `glBindVertexArray`
    # - OpenGL version: 3.0
    @[GLFunction("glBindVertexArray", version: "3.0")]
    def self.unbind(context) : Nil
      none(context).bind
    end

    # Retrieves the name of the element array buffer tied to this vertex array.
    #
    # Returns zero if one isn't associated.
    #
    # - OpenGL function: `glGetVertexArrayiv`
    # - OpenGL enum: `GL_ELEMENT_ARRAY_BUFFER_BINDING`
    # - OpenGL version: 4.5
    @[GLFunction("glGetVertexArrayiv", enum: "GL_ELEMENT_ARRAY_BUFFER_BINDING", version: "4.5")]
    private def element_array_buffer_name
      pname = LibGL::VertexArrayPName.new(LibGL::GetPName::ElementArrayBufferBinding.to_u32!)
      value = uninitialized Int32
      gl.get_vertex_array_iv(to_unsafe, pname, pointerof(value))
      Name.new!(value)
    end

    # Retrieves the element array buffer tied to this vertex array.
    #
    # Returns `nil` if one isn't associated.
    #
    # - OpenGL function: `glGetVertexArrayiv`
    # - OpenGL enum: `GL_ELEMENT_ARRAY_BUFFER_BINDING`
    # - OpenGL version: 4.5
    @[GLFunction("glGetVertexArrayiv", enum: "GL_ELEMENT_ARRAY_BUFFER_BINDING", version: "4.5")]
    def element_array_buffer? : Buffer?
      return if (name = element_array_buffer_name).zero?

      Buffer.new(@context, name)
    end

    # Retrieves the element array buffer tied to this vertex array.
    #
    # Returns `Buffer.none` if one isn't associated.
    #
    # - OpenGL function: `glGetVertexArrayiv`
    # - OpenGL enum: `GL_ELEMENT_ARRAY_BUFFER_BINDING`
    # - OpenGL version: 4.5
    @[GLFunction("glGetVertexArrayiv", enum: "GL_ELEMENT_ARRAY_BUFFER_BINDING", version: "4.5")]
    def element_array_buffer : Buffer
      name = element_array_buffer_name
      Buffer.new(@context, name)
    end

    # Sets the element array buffer used for indexed drawing calls.
    #
    # - OpenGL function: `glVertexArrayElementBuffer`
    # - OpenGL version: 4.5
    @[GLFunction("glVertexArrayElementBuffer", version: "4.5")]
    def element_array_buffer=(buffer : Buffer)
      gl.vertex_array_element_buffer(to_unsafe, buffer.to_unsafe)
    end

    # Information for all attributes in this vertex array.
    def attributes : Attributes
      Attributes.new(@context, @name)
    end

    # Ties a vertex buffer to a binding slot (index) to be associated with an attribute.
    #
    # See: `#bind_attribute`
    #
    # - OpenGL function: `glVertexArrayVertexBuffer`
    # - OpenGL version: 4.5
    @[GLFunction("glVertexArrayVertexBuffer", version: "4.5")]
    def bind_vertex_buffer(buffer : Buffer, to slot : UInt32, offset : Size, stride : Int32)
      gl.vertex_array_vertex_buffer(@name, slot, buffer.to_unsafe, offset, stride)
    end

    # TODO: bind_vertex_buffers

    # Ties an attribute to a binding slot (index) to be associated with a vertex buffer.
    #
    # See: `#bind_vertex_buffer`
    #
    # - OpenGL function: `glVertexArrayAttribBinding`
    # - OpenGL version: 4.5
    @[GLFunction("glVertexArrayAttribBinding", version: "4.5")]
    def bind_attribute(attribute : Attribute, to slot : UInt32)
      gl.vertex_array_attrib_binding(@name, attribute.index, slot)
    end

    # Information about vertex buffer and attribute binding slots.
    def bindings : Bindings
      Bindings.new(@context, @name)
    end
  end

  struct Context
    # Creates a vertex array in this context.
    #
    # See: `VertexArray.create`
    def create_vertex_array : VertexArray
      VertexArray.create(self)
    end

    # Creates multiple vertex arrays in this context.
    #
    # See: `VertexArrayList.create`
    def create_vertex_arrays(count : Int) : VertexArrayList
      VertexArrayList.create(self, count)
    end

    # Generates a vertex array in this context.
    #
    # See: `VertexArray.generate`
    def generate_vertex_array : VertexArray
      VertexArray.generate(self)
    end

    # Generates multiple vertex arrays in this context.
    #
    # See: `VertexArrayList.generate`
    def generate_vertex_arrays(count : Int) : VertexArrayList
      VertexArrayList.generate(self, count)
    end

    # Retrieves the currently bound vertex array.
    #
    # Returns a `nil` if there isn't a vertex array bound.
    #
    # See: `VertexArray.current?`
    def vertex_array? : VertexArray?
      VertexArray.current?(self)
    end

    # Retrieves the currently bound vertex array.
    #
    # Returns a null-object (`Object.none`) if there isn't a vertex array bound.
    #
    # See: `VertexArray.current`
    def vertex_array : VertexArray
      VertexArray.current(self)
    end

    # Unbinds any existing vertex array from the context's rendering state.
    #
    # See: `VertexArray.unbind`
    def unbind_vertex_array : Nil
      VertexArray.unbind(self)
    end
  end

  # Collection of vertex arrays belonging to the same context.
  struct VertexArrayList < ObjectList(VertexArray)
    # Creates multiple new vertex arrays.
    #
    # The number of vertex arrays to create is given by *count*.
    # Unlike `.generate`, resources are created in advance instead of on the first binding.
    #
    # - OpenGL function: `glCreateVertexArrays`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateVertexArrays", version: "4.5")]
    def self.create(context, count : Int) : self
      new(context, count) do |names|
        context.gl.create_vertex_arrays(count, names)
      end
    end

    # Generates multiple new vertex arrays.
    #
    # This ensures unique names for the vertex array objects.
    # Resources are not allocated for the vertex arrays until they are bound.
    #
    # See: `.create`
    #
    # - OpenGL function: `glGenVertexArrays`
    # - OpenGL version: 3.0
    @[GLFunction("glGenVertexArrays", version: "3.0")]
    def self.generate(context, count : Int) : self
      new(context, count) do |names|
        context.gl.gen_vertex_arrays(count, names)
      end
    end

    # Deletes all vertex arrays in the list.
    #
    # - OpenGL function: `glDeleteVertexArrays`
    # - OpenGL version: 3.0
    @[GLFunction("glDeleteVertexArrays", version: "3.0")]
    def delete : Nil
      gl.delete_vertex_arrays(size, to_unsafe)
    end
  end
end
