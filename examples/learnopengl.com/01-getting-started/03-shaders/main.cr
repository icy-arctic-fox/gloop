# Original post available here:
# https://learnopengl.com/Getting-started/Shaders
# and source code available here:
# https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/3.3.shaders_class/shaders_class.cpp

require "glfw"
require "gloop"
require "./shader"

# settings
SCR_WIDTH  = 800
SCR_HEIGHT = 600

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
our_shader = Shader.new("shader.vs", "shader.fs") # you can name your shader files however you like

# set up vertex data (and buffer(s)) and configure vertex attributes
# ------------------------------------------------------------------
vertices = Float32.static_array(
  # positions       # colors
  0.5, -0.5, 0.0, 1.0, 0.0, 0.0,  # bottom right
  -0.5, -0.5, 0.0, 0.0, 1.0, 0.0, # bottom left
  0.0, 0.5, 0.0, 0.0, 0.0, 1.0    # top
)

LibGL.gen_vertex_arrays(1, out vao)
LibGL.gen_buffers(1, out vbo)
# bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
LibGL.bind_vertex_array(vao)

LibGL.bind_buffer(LibGL::BufferTargetARB::ArrayBuffer, vbo)
LibGL.buffer_data(LibGL::BufferTargetARB::ArrayBuffer, sizeof(typeof(vertices)), vertices, LibGL::BufferUsageARB::StaticDraw)

# position attribute
LibGL.vertex_attrib_pointer(0, 3, LibGL::VertexAttribPointerType::Float, LibGL::Boolean::False, 6 * sizeof(Float32), nil)
LibGL.enable_vertex_attrib_array(0)
# color attribute
LibGL.vertex_attrib_pointer(1, 3, LibGL::VertexAttribPointerType::Float, LibGL::Boolean::False, 6 * sizeof(Float32), Pointer(Void).new(3 * sizeof(Float32)))
LibGL.enable_vertex_attrib_array(1)

# note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
LibGL.bind_buffer(LibGL::BufferTargetARB::ArrayBuffer, 0)

# You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
# VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
# LibGL.bind_vertex_array(0)

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

  # render the triangle
  our_shader.use
  LibGL.bind_vertex_array(vao)
  LibGL.draw_arrays(LibGL::PrimitiveType::Triangles, 0, 3)

  # glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
  # -------------------------------------------------------------------------------
  LibGLFW.swap_buffers(window)
  LibGLFW.poll_events
end

# optional: de-allocate all resources once they've outlived their purpose:
# ------------------------------------------------------------------------
LibGL.delete_vertex_arrays(1, pointerof(vao))
LibGL.delete_buffers(1, pointerof(vbo))

# glfw: terminate, clearing all previously allocated GLFW resources.
# ------------------------------------------------------------------
LibGLFW.terminate