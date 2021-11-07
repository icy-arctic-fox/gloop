module Gloop
  # Metadata for an active uniform in a program.
  struct Uniform
    # Type of data stored in the uniform.
    enum Type : UInt32
      Int32                           = LibGL::UniformType::Int
      UInt32                          = LibGL::UniformType::UnsignedInt
      Float32                         = LibGL::UniformType::Float
      Float64                         = LibGL::UniformType::Double
      Float32Vec2                     = LibGL::UniformType::FloatVec2
      Float32Vec3                     = LibGL::UniformType::FloatVec3
      Float32Vec4                     = LibGL::UniformType::FloatVec4
      Int32Vec2                       = LibGL::UniformType::IntVec2
      Int32Vec3                       = LibGL::UniformType::IntVec3
      Int32Vec4                       = LibGL::UniformType::IntVec4
      Bool                            = LibGL::UniformType::Bool
      BoolVec2                        = LibGL::UniformType::BoolVec2
      BoolVec3                        = LibGL::UniformType::BoolVec3
      BoolVec4                        = LibGL::UniformType::BoolVec4
      Float32Mat2                     = LibGL::UniformType::FloatMat2
      Float32Mat3                     = LibGL::UniformType::FloatMat3
      Float32Mat4                     = LibGL::UniformType::FloatMat4
      Sampler1D                       = LibGL::UniformType::Sampler1D
      Sampler2D                       = LibGL::UniformType::Sampler2D
      Sampler3D                       = LibGL::UniformType::Sampler3D
      SamplerCube                     = LibGL::UniformType::SamplerCube
      Sampler1DShadow                 = LibGL::UniformType::Sampler1DShadow
      Sampler2DShadow                 = LibGL::UniformType::Sampler2DShadow
      Float32Mat2x3                   = LibGL::UniformType::FloatMat2x3
      Float32Mat2x4                   = LibGL::UniformType::FloatMat2x4
      Float32Mat3x2                   = LibGL::UniformType::FloatMat3x2
      Float32Mat3x4                   = LibGL::UniformType::FloatMat3x4
      Float32Mat4x2                   = LibGL::UniformType::FloatMat4x2
      Float32Mat4x3                   = LibGL::UniformType::FloatMat4x3
      Sampler1DArray                  = LibGL::UniformType::Sampler1DArray
      Sampler2DArray                  = LibGL::UniformType::Sampler2DArray
      Sampler1DArrayShadow            = LibGL::UniformType::Sampler1DArrayShadow
      Sampler2DArrayShadow            = LibGL::UniformType::Sampler2DArrayShadow
      SamplerCubeShadow               = LibGL::UniformType::SamplerCubeShadow
      UInt32Vec2                      = LibGL::UniformType::UnsignedIntVec2
      UInt32Vec3                      = LibGL::UniformType::UnsignedIntVec3
      UInt32Vec4                      = LibGL::UniformType::UnsignedIntVec4
      Int32Sampler1D                  = LibGL::UniformType::IntSampler1D
      Int32Sampler2D                  = LibGL::UniformType::IntSampler2D
      Int32Sampler3D                  = LibGL::UniformType::IntSampler3D
      Int32SamplerCube                = LibGL::UniformType::IntSamplerCube
      Int32Sampler1DArray             = LibGL::UniformType::IntSampler1DArray
      Int32Sampler2DArray             = LibGL::UniformType::IntSampler2DArray
      UInt32Sampler1D                 = LibGL::UniformType::UnsignedIntSampler1D
      UInt32Sampler2D                 = LibGL::UniformType::UnsignedIntSampler2D
      UInt32Sampler3D                 = LibGL::UniformType::UnsignedIntSampler3D
      UInt32SamplerCube               = LibGL::UniformType::UnsignedIntSamplerCube
      UInt32Sampler1DArray            = LibGL::UniformType::UnsignedIntSampler1DArray
      UInt32Sampler2DArray            = LibGL::UniformType::UnsignedIntSampler2DArray
      Sampler2DRect                   = LibGL::UniformType::Sampler2DRect
      Sampler2DRectShadow             = LibGL::UniformType::Sampler2DRectShadow
      SamplerBuffer                   = LibGL::UniformType::SamplerBuffer
      Int32Sampler2DRect              = LibGL::UniformType::IntSampler2DRect
      Int32SamplerBuffer              = LibGL::UniformType::IntSamplerBuffer
      UInt32Sampler2DRect             = LibGL::UniformType::UnsignedIntSampler2DRect
      UInt32SamplerBuffer             = LibGL::UniformType::UnsignedIntSamplerBuffer
      Sampler2DMultisample            = LibGL::UniformType::Sampler2DMultisample
      Int32Sampler2DMultisample       = LibGL::UniformType::IntSampler2DMultisample
      UInt32Sampler2DMultisample      = LibGL::UniformType::UnsignedIntSampler2DMultisample
      Sampler2DMultisampleArray       = LibGL::UniformType::Sampler2DMultisampleArray
      Int32Sampler2DMultisampleArray  = LibGL::UniformType::IntSampler2DMultisampleArray
      UInt32Sampler2DMultisampleArray = LibGL::UniformType::UnsignedIntSampler2DMultisampleArray
      SamplerCubeMapArray             = LibGL::UniformType::SamplerCubeMapArray
      SamplerCubeMapArrayShadow       = LibGL::UniformType::SamplerCubeMapArrayShadow
      Int32SamplerCubeMapArray        = LibGL::UniformType::IntSamplerCubeMapArray
      UInt32SamplerCubeMapArray       = LibGL::UniformType::UnsignedIntSamplerCubeMapArray
      Float64Vec2                     = LibGL::UniformType::DoubleVec2
      Float64Vec3                     = LibGL::UniformType::DoubleVec3
      Float64Vec4                     = LibGL::UniformType::DoubleVec4
      Float64Mat2                     = LibGL::UniformType::DoubleMat2
      Float64Mat3                     = LibGL::UniformType::DoubleMat3
      Float64Mat4                     = LibGL::UniformType::DoubleMat4
      Float64Mat2x3                   = LibGL::UniformType::DoubleMat2x3
      Float64Mat2x4                   = LibGL::UniformType::DoubleMat2x4
      Float64Mat3x2                   = LibGL::UniformType::DoubleMat3x2
      Float64Mat3x4                   = LibGL::UniformType::DoubleMat3x4
      Float64Mat4x2                   = LibGL::UniformType::DoubleMat4x2
      Float64Mat4x3                   = LibGL::UniformType::DoubleMat4x3

      # Converts to an OpenGL enum.
      def to_unsafe
        LibGL::UniformType.new(value)
      end
    end

    # Name of the uniform.
    #
    # The name may include '.' and '[]' operators.
    # This indicates a sub-item of a structure or array is referenced.
    getter name : String

    # Type of data stored by the uniform.
    getter type : Type

    # Number of elements in the uniform if it's an array.
    getter size : Int32

    # Creates metadata about an active uniform from a program.
    def initialize(@name : String, @type : Type, @size : Int32 = 1)
    end

    # Checks whether the uniform references an array.
    def array?
      size != 1
    end
  end
end
