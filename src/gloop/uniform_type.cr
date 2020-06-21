require "opengl"

module Gloop
  # Types of uniforms.
  enum UniformType : UInt32
    # int
    Int32 = LibGL::UniformType::Int

    # unsigned int
    UInt32 = LibGL::UniformType::UnsignedInt

    # float
    Float32 = LibGL::UniformType::Float

    # double
    Float64 = LibGL::UniformType::Double

    # vec2
    Float32Vector2 = LibGL::UniformType::FloatVec2

    # vec3
    Float32Vector3 = LibGL::UniformType::FloatVec3

    # vec4
    Float32Vector4 = LibGL::UniformType::FloatVec4

    # ivec2
    Int32Vector2 = LibGL::UniformType::IntVec2

    # ivec3
    Int32Vector3 = LibGL::UniformType::IntVec3

    # ivec4
    Int32Vector4 = LibGL::UniformType::IntVec4

    # bool
    Bool = LibGL::UniformType::Bool

    # bvec2
    BoolVector2 = LibGL::UniformType::BoolVec2

    # bvec3
    BoolVector3 = LibGL::UniformType::BoolVec3

    # bvec4
    BoolVector4 = LibGL::UniformType::BoolVec4

    # mat2
    Float32Matrix2x2 = LibGL::UniformType::FloatMat2

    # mat3
    Float32Matrix3x3 = LibGL::UniformType::FloatMat3

    # mat4
    Float32Matrix4x4 = LibGL::UniformType::FloatMat4

    # sampler1D
    Float32Sampler1D = LibGL::UniformType::Sampler1D

    # sampler2D
    Float32Sampler2D = LibGL::UniformType::Sampler2D

    # sampler3D
    Float32Sampler3D = LibGL::UniformType::Sampler3D

    # samplerCube
    Float32SamplerCube = LibGL::UniformType::SamplerCube

    # sampler1DShadow
    Float32Sampler1DShadow = LibGL::UniformType::Sampler1DShadow

    # sampler2DShadow
    Float32Sampler2DShadow = LibGL::UniformType::Sampler2DShadow

    # mat2x3
    Float32Matrix2x3 = LibGL::UniformType::FloatMat2x3

    # mat2x4
    Float32Matrix2x4 = LibGL::UniformType::FloatMat2x4

    # mat3x2
    Float32Matrix3x2 = LibGL::UniformType::FloatMat3x2

    # mat3x4
    Float32Matrix3x4 = LibGL::UniformType::FloatMat3x4

    # mat4x2
    Float32Matrix4x2 = LibGL::UniformType::FloatMat4x2

    # mat4x3
    Float32Matrix4x3 = LibGL::UniformType::FloatMat4x3

    # sampler1DArray
    Float32Sampler1DArray = LibGL::UniformType::Sampler1DArray

    # sampler2DArray
    Float32Sampler2DArray = LibGL::UniformType::Sampler2DArray

    # sampler1DArrayShadow
    Sampler1DArrayShadow = LibGL::UniformType::Sampler1DArrayShadow

    # sampler2DArrayShadow
    Sampler2DArrayShadow = LibGL::UniformType::Sampler2DArrayShadow

    # samplerCubeShadow
    SamplerCubeShadow = LibGL::UniformType::SamplerCubeShadow

    # uvec2
    UInt32Vector2 = LibGL::UniformType::UnsignedIntVec2

    # uvec3
    UInt32Vector3 = LibGL::UniformType::UnsignedIntVec3

    # uvec4
    UInt32Vector4 = LibGL::UniformType::UnsignedIntVec4

    # isampler1D
    Int32Sampler1D = LibGL::UniformType::IntSampler1D

    # isampler2D
    Int32Sampler2D = LibGL::UniformType::IntSampler2D

    # isampler3D
    Int32Sampler3D = LibGL::UniformType::IntSampler3D

    # isamplerCube
    Int32SamplerCube = LibGL::UniformType::IntSamplerCube

    # isampler1DArray
    Int32Sampler1DArray = LibGL::UniformType::IntSampler1DArray

    # isampler2DArray
    Int32Sampler2DArray = LibGL::UniformType::IntSampler2DArray

    # usampler1D
    UInt32Sampler1D = LibGL::UniformType::UnsignedIntSampler1D

    # usampler2D
    UInt32Sampler2D = LibGL::UniformType::UnsignedIntSampler2D

    # usampler3D
    UInt32Sampler3D = LibGL::UniformType::UnsignedIntSampler3D

    # usamplerCube
    UInt32SamplerCube = LibGL::UniformType::UnsignedIntSamplerCube

    # usampler1DArray
    UInt32Sampler1DArray = LibGL::UniformType::UnsignedIntSampler1DArray

    # usampler2DArray
    UInt32Sampler2DArray = LibGL::UniformType::UnsignedIntSampler2DArray

    # sampler2DRect
    Float32Sampler2DRect = LibGL::UniformType::Sampler2DRect

    # sampler2DRectShadow
    Float32Sampler2DRectShadow = LibGL::UniformType::Sampler2DRectShadow

    # samplerBuffer
    Float32SamplerBuffer = LibGL::UniformType::SamplerBuffer

    # isampler2DRect
    Int32Sampler2DRect = LibGL::UniformType::IntSampler2DRect

    # isamplerBuffer
    Int32SamplerBuffer = LibGL::UniformType::IntSamplerBuffer

    # usampler2DRect
    UInt32Sampler2DRect = LibGL::UniformType::UnsignedIntSampler2DRect

    # usamplerBuffer
    UInt32SamplerBuffer = LibGL::UniformType::UnsignedIntSamplerBuffer

    # sampler2DMS
    Float32Sampler2DMultisample = LibGL::UniformType::Sampler2DMultisample

    # isampler2DMS
    Int32Sampler2DMultisample = LibGL::UniformType::IntSampler2DMultisample

    # usampler2DMS
    UInt32Sampler2DMultisample = LibGL::UniformType::UnsignedIntSampler2DMultisample

    # sampler2DMSArray
    Float32Sampler2DMultisampleArray = LibGL::UniformType::Sampler2DMultisampleArray

    # isampler2DMSArray
    Int32Sampler2DMultisampleArray = LibGL::UniformType::IntSampler2DMultisampleArray

    # usampler2DMSArray
    UInt32Sampler2DMultisampleArray = LibGL::UniformType::UnsignedIntSampler2DMultisampleArray

    # samplerCubeMapArray
    Float32SamplerCubeMapArray = LibGL::UniformType::SamplerCubeMapArray

    # samplerCubeMapArrayShadow
    Float32SamplerCubeMapArrayShadow = LibGL::UniformType::SamplerCubeMapArrayShadow

    # isamplerCubeMapArray
    Int32SamplerCubeMapArray = LibGL::UniformType::IntSamplerCubeMapArray

    # usamplerCubeMapArray
    UInt32SamplerCubeMapArray = LibGL::UniformType::UnsignedIntSamplerCubeMapArray

    # dvec2
    Float64Vector2 = LibGL::UniformType::DoubleVec2

    # dvec3
    Float64Vector3 = LibGL::UniformType::DoubleVec3

    # dvec4
    Float64Vector4 = LibGL::UniformType::DoubleVec4

    # dmat2
    Float64Matrix2x2 = LibGL::UniformType::DoubleMat2

    # dmat3
    Float64Matrix3x3 = LibGL::UniformType::DoubleMat3

    # dmat4
    Float64Matrix4x4 = LibGL::UniformType::DoubleMat4

    # dmat2x3
    Float64Matrix2x3 = LibGL::UniformType::DoubleMat2x3

    # dmat2x4
    Float64Matrix2x4 = LibGL::UniformType::DoubleMat2x4

    # dmat3x2
    Float64Matrix3x2 = LibGL::UniformType::DoubleMat3x2

    # dmat3x4
    Float64Matrix3x4 = LibGL::UniformType::DoubleMat3x4

    # dmat4x2
    Float64Matrix4x2 = LibGL::UniformType::DoubleMat4x2

    # dmat4x3
    Float64Matrix4x3 = LibGL::UniformType::DoubleMat4x3
  end
end
