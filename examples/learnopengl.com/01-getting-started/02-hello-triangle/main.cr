# Original post available here:
# https://learnopengl.com/Getting-started/Hello-Triangle
# and source code available here:
# https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/2.2.hello_triangle_indexed/hello_triangle_indexed.cpp

require "glfw"
require "gloop"

# settings
SCR_WIDTH  = 800
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
context = Gloop::Context.from_glfw

# build and compile our shader program
# ------------------------------------
# vertex shader
vertex_shader = context.create_shader(:vertex)
vertex_shader.source = VERTEX_SHADER_SOURCE
vertex_shader.compile
# check for shader compile errors
unless vertex_shader.compiled?
  puts "ERROR::SHADER::VERTEX::COMPILATION_FAILED"
  puts vertex_shader.info_log
end
# fragment shader
fragment_shader = context.create_shader(:fragment)
fragment_shader.source = FRAGMENT_SHADER_SOURCE
fragment_shader.compile
# check for shader compile errors
unless fragment_shader.compiled?
  puts "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED"
  puts fragment_shader.info_log
end
# link shaders
shader_program = context.create_program
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
  0.5, 0.5, 0.0,   # top right
  0.5, -0.5, 0.0,  # bottom right
  -0.5, -0.5, 0.0, # bottom left
  -0.5, 0.5, 0.0   # top left
)
indices = UInt32.static_array( # note that we start from 0!
0, 1, 3,                       # first Triangle
  1, 2, 3                      # second Triangle
)
vao = context.generate_vertex_array
vbo = context.generate_buffer
ebo = context.generate_buffer
# bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
vao.bind

context.buffers.array.bind(vbo)
context.buffers.array.data(vertices, :static_draw)

context.buffers.element_array.bind(ebo)
context.buffers.element_array.data(indices, :static_draw)

attribute = context.attributes[0]
attribute.float32_pointer(3, :float32, false, 3 * sizeof(Float32), 0)
attribute.enable

# note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
context.buffers.array.unbind

# remember: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
# context.buffers.element_array.unbind

# You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
# VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
context.unbind_vertex_array

# uncomment this call to draw in wireframe polygons.
# LibGL.polygon_mode(LibGL::MaterialFace::FrontAndBack, LibGL::PolygonMode::Line)

# render loop
# -----------
while LibGLFW.window_should_close(window).false?
  # input
  # -----
  process_input(window)

  # render
  # ------
  context.clear_color = {0.2, 0.3, 0.3, 1.0}
  context.clear(:color)

  # draw our first triangle
  shader_program.use
  vao.bind # seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
  # context.draw_arrays(:triangles, 0, 6)
  context.draw_elements(:triangles, 6, :u_int32, 0)
  # context.unbind_vertex_array # no need to unbind it every time

  # glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
  # -------------------------------------------------------------------------------
  LibGLFW.swap_buffers(window)
  LibGLFW.poll_events
end

# optional: de-allocate all resources once they've outlived their purpose:
# ------------------------------------------------------------------------
vao.delete
vbo.delete
ebo.delete
shader_program.delete

# glfw: terminate, clearing all previously allocated GLFW resources.
# ------------------------------------------------------------------
LibGLFW.terminate
