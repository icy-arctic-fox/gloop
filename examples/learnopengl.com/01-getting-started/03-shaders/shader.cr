# Original post available here:
# https://learnopengl.com/Getting-started/Shaders
# and source code available here:
# https://learnopengl.com/code_viewer_gh.php?code=includes/learnopengl/shader_s.h

require "gloop"

class Shader
  getter program : Gloop::Program

  # constructor generates the shader on the fly
  # ------------------------------------------------------------------------
  def initialize(vertex_path, fragment_path)
    # 1. retrieve the vertex/fragment source code from filePath
    v_shader_code = File.read(vertex_path)
    f_shader_code = File.read(fragment_path)
    # 2. compile shaders
    # vertex shader
    vertex = Gloop::VertexShader.create
    vertex.source = v_shader_code
    vertex.compile
    check_compile_errors(vertex)
    # fragment Shader
    fragment = Gloop::FragmentShader.create
    fragment.source = f_shader_code
    fragment.compile
    check_compile_errors(fragment)
    # shader Program
    @program = Gloop::Program.create
    @program.attach(vertex)
    @program.attach(fragment)
    @program.link
    check_compile_errors(@program)
    # delete the shaders as they're linked into our program now and no longer necessary
    vertex.delete
    fragment.delete
  end

  # activate the shader
  # ------------------------------------------------------------------------
  def use
    @program.activate
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
