module Gloop
  abstract struct Shader < Object
    # Class methods available on all shader types.
    module ClassMethods
      # Creates a new shader.
      #
      # Effectively calls:
      # ```c
      # glCreateShader(shader_type)
      # ```
      #
      # Minimum required version: 2.0
      def create
        name = expect_truthy do
          LibGL.create_shader(type)
        end
        new(name)
      end

      # Creates a new shader and compiles it.
      # The new shader is returned.
      #
      # Effectively calls:
      # ```c
      # shader = glCreateShader(shader_type)
      # glShaderSource(shader, 1, &source, NULL)
      # glCompileShader(shader)
      # ```
      #
      # Minimum required version: 2.0
      def compile(source)
        create.tap do |shader|
          shader.source = source
          shader.compile
        end
      end

      # Creates a new shader and compiles it.
      # The shader is returned on successful compilation.
      # Raises an error if the shader creation or compilation failed.
      #
      # Effectively calls:
      # ```c
      # shader = glCreateShader(shader_type)
      # glShaderSource(shader, 1, &source, NULL)
      # glCompileShader(shader)
      # ```
      #
      # Minimum required version: 2.0
      def compile!(source)
        create.tap do |shader|
          shader.source = source
          shader.compile!
        end
      end
    end
  end
end
