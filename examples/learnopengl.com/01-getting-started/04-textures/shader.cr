# Original post available here:
# https://learnopengl.com/Getting-started/Textures
# and source code available here:
# https://learnopengl.com/code_viewer_gh.php?code=includes/learnopengl/shader.h

require "gloop"

class Shader
  getter program : Gloop::Program

  # constructor generates the shader on the fly
  # ------------------------------------------------------------------------
  def initialize(context, vertex_path, fragment_path, geometry_path = nil)
    # 1. retrieve the vertex/fragment source code from filePath
    v_shader_code = File.read(vertex_path)
    f_shader_code = File.read(fragment_path)
    g_shader_code = File.read(geometry_path) if geometry_path
    # 2. compile shaders
    # vertex shader
    vertex = context.create_shader(:vertex)
    vertex.source = v_shader_code
    vertex.compile
    check_compile_errors(vertex)
    # fragment Shader
    fragment = context.create_shader(:fragment)
    fragment.source = f_shader_code
    fragment.compile
    check_compile_errors(fragment)
    # if geometry shader is given, compile geometry shader
    if geometry_path
      geometry = context.create_shader(:geometry)
      geometry.source = g_shader_code
      geometry.compile
      check_compile_errors(geometry)
    end
    # shader Program
    @program = context.create_program
    @program.attach(vertex)
    @program.attach(fragment)
    @program.attach(geometry) if geometry
    @program.link
    check_compile_errors(@program)
    # delete the shaders as they're linked into our program now and no longer necessary
    vertex.delete
    fragment.delete
    geometry.delete if geometry
  end

  def id
    @program.name
  end

  # activate the shader
  # ------------------------------------------------------------------------
  def use
    @program.use
  end

  # utility uniform functions
  # ------------------------------------------------------------------------
  def set_bool(name, value)
    LibGL.uniform_1i(LibGL.get_uniform_location(@program, name), value.to_i32)
  end

  # ------------------------------------------------------------------------
  def set_int(name, value)
    LibGL.uniform_1i(LibGL.get_uniform_location(@program, name), value)
  end

  # ------------------------------------------------------------------------
  def set_float(name, value)
    LibGL.uniform_1f(LibGL.get_uniform_location(@program, name), value)
  end

  # ------------------------------------------------------------------------
  def set_vec2(name, value)
    LibGL.uniform_2fv(LibGL.get_uniform_location(@program, name), value)
  end

  def set_vec2(name, x, y)
    LibGL.uniform_2f(LibGL.get_uniform_location(@program, name), x, y)
  end

  # ------------------------------------------------------------------------
  def set_vec3(name, value)
    LibGL.uniform_3fv(LibGL.get_uniform_location(@program, name), value)
  end

  def set_vec3(name, x, y, z)
    LibGL.uniform_3f(LibGL.get_uniform_location(@program, name), x, y, z)
  end

  # ------------------------------------------------------------------------
  def set_vec4(name, value)
    LibGL.uniform_4fv(LibGL.get_uniform_location(@program, name), value)
  end

  def set_vec4(name, x, y, z, w)
    LibGL.uniform_4f(LibGL.get_uniform_location(@program, name), x, y, z, w)
  end

  # ------------------------------------------------------------------------
  def set_mat2(name, mat)
    LibGL.uniform_matrix_2fv(LibGL.get_uniform_location(@program, name), 1, LibGL::Boolean::False, mat)
  end

  # ------------------------------------------------------------------------
  def set_mat3(name, mat)
    LibGL.uniform_matrix_3fv(LibGL.get_uniform_location(@program, name), 1, LibGL::Boolean::False, mat)
  end

  # ------------------------------------------------------------------------
  def set_mat4(name, mat)
    LibGL.uniform_matrix_4fv(LibGL.get_uniform_location(@program, name), 1, LibGL::Boolean::False, mat)
  end

  # utility function for checking shader compilation/linking errors.
  # ------------------------------------------------------------------------
  private def check_compile_errors(shader : Gloop::Shader)
    return if shader.compiled?

    puts "ERROR::SHADER_COMPILATION_ERROR of type: #{shader.type}"
    puts shader.info_log
    puts " -- --------------------------------------------------- -- "
  end

  private def check_compile_errors(program : Gloop::Program)
    return if program.linked?

    puts "ERROR::PROGRAM_LINKING_ERROR of type: #{program.object_type}"
    puts program.info_log
    puts " -- --------------------------------------------------- -- "
  end
end
