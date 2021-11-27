require "./object"
require "./texture/*"

module Gloop
  # Collection of one or more images.
  #
  # See: https://www.khronos.org/opengl/wiki/Texture
  struct Texture < Object
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
    def self.create(context, type : Target) : self
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
      create(context, Target.new(type))
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
    def bind(target : Target) : Nil
      gl.bind_texture(target.to_unsafe, @name)
    end

    # Binds this texture to a specified target.
    #
    # - OpenGL function: `glBindTexture`
    # - OpenGL version: 2.0
    @[GLFunction("glBindTexture", version: "2.0")]
    @[AlwaysInline]
    def bind(target : Symbol) : Nil
      bind(Target.new(target))
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
    def create_texture(type : Texture::Target) : Texture
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
    def create_textures(type : Texture::Target, count : Int) : TextureList
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
    def self.create(context, type : Texture::Target, count : Int) : self
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
      create(context, Texture::Target.new(type), count)
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
