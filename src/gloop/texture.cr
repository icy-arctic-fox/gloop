require "./object"

module Gloop
  # Collection of one or more images.
  #
  # See: https://www.khronos.org/opengl/wiki/Texture
  struct Texture < Object
    # Types of textures.
    enum Type : UInt32
      Texture1D          = LibGL::TextureTarget::Texture1D
      Texture2D          = LibGL::TextureTarget::Texture2D
      Texture3D          = LibGL::TextureTarget::Texture3D
      Texture1DArray     = LibGL::TextureTarget::Texture1DArray
      Texture2DArray     = LibGL::TextureTarget::Texture2DArray
      Rectangle          = LibGL::TextureTarget::TextureRectangle
      CubeMap            = LibGL::TextureTarget::TextureCubeMap
      CubeMapArray       = LibGL::TextureTarget::TextureCubeMapArray
      Buffer             = LibGL::TextureTarget::TextureBuffer
      MultiSample2D      = LibGL::TextureTarget::Texture2DMultisample
      MultiSample2DArray = LibGL::TextureTarget::Texture2DMultisampleArray

      # Creates a texture type from a symbol.
      #
      # This is intended to be used as a workaround for Crystal's limitations and auto-generated names.
      def self.new(value : Symbol) # ameba:disable Metrics/CyclomaticComplexity
        case value
        when :_1d, :"1d", :texture_1d                   then Texture1D
        when :_2d, :"2d", :texture_2d                   then Texture2D
        when :_3d, :"3d", :texture_3d                   then Texture3D
        when :_1d_array, :"1d_array", :texture_1d_array then Texture1DArray
        when :_2d_array, :"2d_array", :texture_2d_array then Texture2DArray
        when :rectangle                                 then Rectangle
        when :cube_map                                  then CubeMap
        when :cube_map_array                            then CubeMapArray
        when :buffer                                    then Buffer
        when :multi_sample_2d                           then MultiSample2D
        when :multi_sample_2d_array                     then MultiSample2DArray
        else                                                 raise ArgumentError.new("Invalid texture type")
        end
      end

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::TextureTarget.new(value)
      end
    end

    # Generates a new texture.
    #
    # The texture isn't assigned a type or resources until it is bound.
    #
    # See: `#create`
    #
    # - OpenGL function: `glGenTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glGenTextures", version: "2.0")]
    def self.generate(context) : self
      name = uninitialized Name
      context.gl.gen_textures(1, pointerof(name))
      new(context, name)
    end

    # Creates a new texture of the specified type.
    #
    # - OpenGL function: `glCreateTextures`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateTextures", version: "4.5")]
    def self.create(context, type : Type) : self
      name = uninitialized Name
      context.gl.create_textures(type.to_unsafe, 1, pointerof(name))
      new(context, name)
    end

    # Creates a new texture of the specified type.
    #
    # - OpenGL function: `glCreateTextures`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateTextures", version: "4.5")]
    @[AlwaysInline]
    def self.create(context, type : Symbol) : self
      create(context, Type.new(type))
    end

    # Deletes this texture.
    #
    # - OpenGL function: `glDeleteTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteTextures", version: "2.0")]
    def delete
      gl.delete_textures(1, pointerof(@name))
    end

    # Deletes multiple textures.
    #
    # - OpenGL function: `glDeleteTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteTextures", version: "2.0")]
    def self.delete(textures : Enumerable(self)) : Nil
      super do |context, names|
        context.gl.delete_textures(names.size, names.to_unsafe)
      end
    end

    # Checks if the texture is known by OpenGL.
    #
    # - OpenGL function: `glIsTexture`
    # - OpenGL version: 2.0
    @[GLFunction("glIsTexture", version: "2.0")]
    def exists?
      value = gl.is_texture(to_unsafe)
      !value.false?
    end

    # Indicates that this is a texture object.
    def object_type
      Object::Type::Texture
    end

    # Binds this texture to a specified target.
    #
    # - OpenGL function: `glBindTexture`
    # - OpenGL version: 2.0
    @[GLFunction("glBindTexture", version: "2.0")]
    def bind(target : Type) : Nil
      gl.bind_texture(target.to_unsafe, @name)
    end

    # Binds this texture to a specified target.
    #
    # - OpenGL function: `glBindTexture`
    # - OpenGL version: 2.0
    @[GLFunction("glBindTexture", version: "2.0")]
    @[AlwaysInline]
    def bind(target : Symbol) : Nil
      bind(Type.new(target))
    end
  end

  struct Context
    # Generates a new texture.
    #
    # See: `Texture.generate`
    def generate_texture : Texture
      Texture.generate(self)
    end

    # Generates multiple textures.
    #
    # See: `Texture.generate`
    def generate_textures(count : Int) : TextureList
      TextureList.generate(self, count)
    end

    # Creates a new texture of the specified type.
    #
    # See: `Texture.create`
    def create_texture(type : Texture::Type) : Texture
      Texture.create(self, type)
    end

    # Creates a new texture of the specified type.
    #
    # See: `Texture.create`
    def create_texture(type : Symbol) : Texture
      Texture.create(self, type)
    end

    # Creates multiple textures of the specified type.
    #
    # See: `Texture.create`
    def create_textures(type : Texture::Type, count : Int) : TextureList
      TextureList.create(self, type, count)
    end

    # Creates multiple textures of the specified type.
    #
    # See: `Texture.create`
    def create_textures(type : Symbol, count : Int) : TextureList
      TextureList.create(self, type, count)
    end
  end

  # Collection of textures belonging to the same context.
  struct TextureList < ObjectList(Texture)
    # Generates multiple textures.
    #
    # The textures aren't assigned a type or resources until they are bound.
    #
    # See: `#create`
    #
    # - OpenGL function: `glGenTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glGenTextures", version: "2.0")]
    def self.generate(context, count : Int) : self
      new(context, count) do |names|
        context.gl.gen_textures(count, names)
      end
    end

    # Creates multiple textures of the specified type.
    #
    # - OpenGL function: `glCreateTextures`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateTextures", version: "4.5")]
    def self.create(context, type : Texture::Type, count : Int) : self
      new(context, count) do |names|
        context.gl.create_textures(type.to_unsafe, count, names)
      end
    end

    # Creates multiple textures of the specified type.
    #
    # - OpenGL function: `glCreateTextures`
    # - OpenGL version: 4.5
    @[GLFunction("glCreateTextures", version: "4.5")]
    @[AlwaysInline]
    def self.create(context, type : Symbol, count : Int) : self
      create(context, Texture::Type.new(type), count)
    end

    # Deletes all textures in the list.
    #
    # - OpenGL function: `glDeleteTextures`
    # - OpenGL version: 2.0
    @[GLFunction("glDeleteTextures", version: "2.0")]
    def delete : Nil
      gl.delete_textures(size, to_unsafe)
    end
  end
end
