# Original post available here:
# https://learnopengl.com/Getting-started/Textures
# and source code available here:
# https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/4.2.textures_combined/textures_combined.cpp

require "glfw"
require "gloop"
require "lib_stb_image"
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
  context = LibGLFW.get_window_user_pointer(window).as(Gloop::Context*).value
  # make sure the viewport matches the new window dimensions; note that width and
  # height will be significantly larger than specified on retina displays.
  context.viewport = {0, 0, width, height}
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
context = Gloop::Context.from_glfw
LibGLFW.set_window_user_pointer(window, pointerof(context))
LibGLFW.set_framebuffer_size_callback(window, ->framebuffer_size_callback)

# build and compile our shader program
# ------------------------------------
our_shader = Shader.new(context, "texture.vs", "texture.fs") # you can name your shader files however you like

# set up vertex data (and buffer(s)) and configure vertex attributes
# ------------------------------------------------------------------
vertices = Float32.static_array(
  # positions      # colors       # texture coords
  0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0,   # top right
  0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0,  # bottom right
  -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, # bottom left
  -0.5, 0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0   # top left
)
indices = Int32.static_array(
  0, 1, 3, # first triangle
  1, 2, 3  # second triangle
)

vao = context.generate_vertex_array
vbo = context.generate_buffer
ebo = context.generate_buffer

vao.bind

context.buffers.array.bind(vbo)
context.buffers.array.initialize_data(vertices, :static_draw)

context.buffers.element_array.bind(ebo)
context.buffers.element_array.initialize_data(indices, :static_draw)

# position attribute
attribute = context.attributes[0]
attribute.float32_pointer(3, :float32, false, 8 * sizeof(Float32), 0)
attribute.enable
# color attribute
attribute = context.attributes[1]
attribute.float32_pointer(3, :float32, false, 8 * sizeof(Float32), 3_i64 * sizeof(Float32))
attribute.enable
# texture coord attribute
attribute = context.attributes[2]
attribute.float32_pointer(2, :float32, false, 8 * sizeof(Float32), 6_i64 * sizeof(Float32))
attribute.enable

# load and create a texture
# -------------------------

# texture 1
# ---------
LibGL.gen_textures(1, out texture_1)
LibGL.bind_texture(LibGL::TextureTarget::Texture2D, texture_1)
# set the texture wrapping parameters
LibGL.tex_parameter_i(LibGL::TextureTarget::Texture2D, LibGL::TextureParameterName::TextureWrapS, LibGL::TextureWrapMode::Repeat) # set texture wrapping to GL_REPEAT (default wrapping method)
LibGL.tex_parameter_i(LibGL::TextureTarget::Texture2D, LibGL::TextureParameterName::TextureWrapT, LibGL::TextureWrapMode::Repeat)
# set texture filtering parameters
LibGL.tex_parameter_i(LibGL::TextureTarget::Texture2D, LibGL::TextureParameterName::TextureMinFilter, LibGL::TextureMinFilter::Linear)
LibGL.tex_parameter_i(LibGL::TextureTarget::Texture2D, LibGL::TextureParameterName::TextureMagFilter, LibGL::TextureMagFilter::Linear)
# load image, create texture and generate mipmaps
LibSTBImage.set_flip_vertically_on_load(1) # tell stb_image.h to flip loaded texture's on the y-axis.
data = LibSTBImage.load("resources/textures/container.jpg", out width, out height, out channels, 0)
if data
  LibGL.tex_image_2d(LibGL::TextureTarget::Texture2D, 0, LibGL::InternalFormat::RGB, width, height, 0, LibGL::PixelFormat::RGB, LibGL::PixelType::UnsignedByte, data)
  LibGL.generate_mipmap(LibGL::TextureTarget::Texture2D)
else
  puts "Failed to load texture"
end
LibSTBImage.image_free(data)
# texture 2
# ---------
LibGL.gen_textures(1, out texture_2)
LibGL.bind_texture(LibGL::TextureTarget::Texture2D, texture_2)
# set the texture wrapping parameters
LibGL.tex_parameter_i(LibGL::TextureTarget::Texture2D, LibGL::TextureParameterName::TextureWrapS, LibGL::TextureWrapMode::Repeat) # set texture wrapping to GL_REPEAT (default wrapping method)
LibGL.tex_parameter_i(LibGL::TextureTarget::Texture2D, LibGL::TextureParameterName::TextureWrapT, LibGL::TextureWrapMode::Repeat)
# set texture filtering parameters
LibGL.tex_parameter_i(LibGL::TextureTarget::Texture2D, LibGL::TextureParameterName::TextureMinFilter, LibGL::TextureMinFilter::Linear)
LibGL.tex_parameter_i(LibGL::TextureTarget::Texture2D, LibGL::TextureParameterName::TextureMagFilter, LibGL::TextureMagFilter::Linear)
# load image, create texture and generate mipmaps
data = LibSTBImage.load("resources/textures/awesomeface.png", pointerof(width), pointerof(height), pointerof(channels), 0)
if data
  LibGL.tex_image_2d(LibGL::TextureTarget::Texture2D, 0, LibGL::InternalFormat::RGBA, width, height, 0, LibGL::PixelFormat::RGBA, LibGL::PixelType::UnsignedByte, data)
  LibGL.generate_mipmap(LibGL::TextureTarget::Texture2D)
else
  puts "Failed to load texture"
end
LibSTBImage.image_free(data)

# tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
# -------------------------------------------------------------------------------------------
our_shader.use # don't forget to activate/use the shader before setting uniforms!
# either set it manually like so:
LibGL.uniform_1i(LibGL.get_uniform_location(our_shader.id, "texture1"), 0)
# or set it via the shader class
our_shader.set_int("texture2", 1)

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

  # bind textures on corresponding texture units
  LibGL.active_texture(LibGL::TextureUnit::Texture0)
  LibGL.bind_texture(LibGL::TextureTarget::Texture2D, texture_1)
  LibGL.active_texture(LibGL::TextureUnit::Texture1)
  LibGL.bind_texture(LibGL::TextureTarget::Texture2D, texture_2)

  # render container
  our_shader.use
  vao.bind
  context.draw_elements(:triangles, 6, :u_int32, 0)

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

# glfw: terminate, clearing all previously allocated GLFW resources.
# ------------------------------------------------------------------
LibGLFW.terminate
