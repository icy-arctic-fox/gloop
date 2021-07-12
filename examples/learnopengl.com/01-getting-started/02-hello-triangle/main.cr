# Original post available here:
# https://learnopengl.com/Getting-started/Hello-Window
# and source code available here:
# https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/1.2.hello_window_clear/hello_window_clear.cpp

require "glfw"
require "gloop"

# settings
SCR_WIDTH = 800
SCR_HEIGHT = 600

VERTEX_SHADER_SOURCE = <<-SHADER
  #version 330 core
  layout (location = 0) in vec3 aPos;
  void main()
  {
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
  }
SHADER

FRAGMENT_SHADER_SOURCE = <<-SHADER
  #version 330 core
  out vec4 FragColor;
  void main()
  {
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
  }
SHADER

# process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
# ---------------------------------------------------------------------------------------------------------
def process_input(window)
  if LibGLFW.get_key(window, LibGLFW::Key::Escape).press?
    LibGLFW.set_window_should_close(window, LibGLFW::Bool::True)
  end
end

# glfw: whenever the window size changed (by OS or user resize) this callback function executes
# ---------------------------------------------------------------------------------------------
def framebuffer_size_callback(window, width, height)
  # make sure the viewport matches the new window dimensions; note that width and
  # height will be significantly larger than specified on retina displays.
  LibGL.viewport(0, 0, width, height)
end

# glfw: initialize and configure
# ------------------------------
LibGLFW.init
LibGLFW.window_hint(LibGLFW::WindowHint::ContextVersionMajor, 3)
LibGLFW.window_hint(LibGLFW::WindowHint::ContextVersionMinor, 3)
LibGLFW.window_hint(LibGLFW::WindowHint::OpenGLProfile, LibGLFW::OpenGLProfile::Core)

{% if flag?(:darwin) %}
LibGLFW.window_hint(LibGLFW::WindowHint::OpenGLForwardCompat, LibGLFW::Bool::True)
{% end %}

# glfw window creation
# --------------------
window = LibGLFW.create_window(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", nil, nil)
if window.nil?
  puts "Failed to create GLFW window"
  LibGLFW.terminate
  exit -1
end
LibGLFW.make_context_current(window)
LibGLFW.set_framebuffer_size_callback(window, ->framebuffer_size_callback)

# build and compile our shader program
# ------------------------------------
# vertex shader
vertex_shader = Gloop::VertexShader.create
vertex_shader.source = VERTEX_SHADER_SOURCE
vertex_shader.compile
# check for shader compile errors
unless vertex_shader.compiled?
  puts "ERROR::SHADER::VERTEX::COMPILATION_FAILED"
  puts vertex_shader.info_log
end
# fragment shader
fragment_shader = Gloop::FragmentShader.create
fragment_shader.source = FRAGMENT_SHADER_SOURCE
fragment_shader.compile
# check for shader compile errors
unless fragment_shader.compiled?
  puts "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED"
  puts fragment_shader.info_log
end
# link shaders
shader_program = Gloop::Program.create
shader_program.attach(vertex_shader)
shader_program.attach(fragment_shader)
shader_program.link
# check for linking errors
unless shader_program.linked?
  puts "ERROR::SHADER::PROGRAM::LINKING_FAILED"
  puts shader_program.info_log
end
vertex_shader.delete
fragment_shader.delete

# set up vertex data (and buffer(s)) and configure vertex attributes
# ------------------------------------------------------------------
vertices = Float32.static_array(
   0.5,  0.5, 0.0,  # top right
   0.5, -0.5, 0.0,  # bottom right
  -0.5, -0.5, 0.0,  # bottom left
  -0.5,  0.5, 0.0   # top left
)
indices = UInt32.static_array( # note that we start from 0!
  0, 1, 3,  # first Triangle
  1, 2, 3   # second Triangle
)
LibGL.gen_vertex_arrays(1, out vao)
LibGL.gen_buffers(1, out vbo)
LibGL.gen_buffers(1, out ebo)
# bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
LibGL.bind_vertex_array(vao)

LibGL.bind_buffer(LibGL::BufferTargetARB::ArrayBuffer, vbo)
LibGL.buffer_data(LibGL::BufferTargetARB::ArrayBuffer, sizeof(typeof(vertices)), vertices, LibGL::BufferUsageARB::StaticDraw)

LibGL.bind_buffer(LibGL::BufferTargetARB::ElementArrayBuffer, ebo)
LibGL.buffer_data(LibGL::BufferTargetARB::ElementArrayBuffer, sizeof(typeof(indices)), indices, LibGL::BufferUsageARB::StaticDraw)

LibGL.vertex_attrib_pointer(0, 3, LibGL::VertexAttribPointerType::Float, LibGL::Boolean::False, 3 * sizeof(Float32), nil)
LibGL.enable_vertex_attrib_array(0)

# note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
LibGL.bind_buffer(LibGL::BufferTargetARB::ArrayBuffer, 0)

# remember: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
#LibGL.bind_buffer(LibGL::BufferTargetARB::ElementArrayBuffer, 0)

# You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
# VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
LibGL.bind_vertex_array(0)


# uncomment this call to draw in wireframe polygons.
#LibGL.polygon_mode(LibGL::MaterialFace::FrontAndBack, LibGL::PolygonMode::Line)

# render loop
# -----------
while LibGLFW.window_should_close(window).false?
  # input
  # -----
  process_input(window)

  # render
  # ------
  LibGL.clear_color(0.2, 0.3, 0.3, 1.0)
  LibGL.clear(LibGL::ClearBufferMask::ColorBuffer)

  # draw our first triangle
  shader_program.activate
  LibGL.bind_vertex_array(vao) # seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
  #LibGL.draw_arrays(LibGL::PrimitiveType::Triangles, 0, 6)
  LibGL.draw_elements(LibGL::PrimitiveType::Triangles, 6, LibGL::DrawElementsType::UnsignedInt, nil)
  #LibGL.bind_vertex_array(0) # no need to unbind it every time

  # glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
  # -------------------------------------------------------------------------------
  LibGLFW.swap_buffers(window)
  LibGLFW.poll_events
end

# optional: de-allocate all resources once they've outlived their purpose:
# ------------------------------------------------------------------------
LibGL.delete_vertex_arrays(1, pointerof(vao))
LibGL.delete_buffers(1, pointerof(vbo))
LibGL.delete_buffers(1, pointerof(ebo))
shader_program.delete

# glfw: terminate, clearing all previously allocated GLFW resources.
# ------------------------------------------------------------------
LibGLFW.terminate
