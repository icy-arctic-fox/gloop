# Original post available here:
# https://learnopengl.com/Getting-started/Coordinate-Systems
# and source code available here:
# https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/6.3.coordinate_systems_multiple/coordinate_systems_multiple.cpp

require "geode"
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

# configure global opengl state
# -----------------------------
context.enable(:depth_test)

# build and compile our shader program
# ------------------------------------
our_shader = Shader.new(context, "6.3.coordinate_systems.vs", "6.3.coordinate_systems.fs")

# set up vertex data (and buffer(s)) and configure vertex attributes
# ------------------------------------------------------------------
vertices = Float32.static_array(
  -0.5, -0.5, -0.5, 0.0, 0.0,
  0.5, -0.5, -0.5, 1.0, 0.0,
  0.5, 0.5, -0.5, 1.0, 1.0,
  0.5, 0.5, -0.5, 1.0, 1.0,
  -0.5, 0.5, -0.5, 0.0, 1.0,
  -0.5, -0.5, -0.5, 0.0, 0.0,

  -0.5, -0.5, 0.5, 0.0, 0.0,
  0.5, -0.5, 0.5, 1.0, 0.0,
  0.5, 0.5, 0.5, 1.0, 1.0,
  0.5, 0.5, 0.5, 1.0, 1.0,
  -0.5, 0.5, 0.5, 0.0, 1.0,
  -0.5, -0.5, 0.5, 0.0, 0.0,

  -0.5, 0.5, 0.5, 1.0, 0.0,
  -0.5, 0.5, -0.5, 1.0, 1.0,
  -0.5, -0.5, -0.5, 0.0, 1.0,
  -0.5, -0.5, -0.5, 0.0, 1.0,
  -0.5, -0.5, 0.5, 0.0, 0.0,
  -0.5, 0.5, 0.5, 1.0, 0.0,

  0.5, 0.5, 0.5, 1.0, 0.0,
  0.5, 0.5, -0.5, 1.0, 1.0,
  0.5, -0.5, -0.5, 0.0, 1.0,
  0.5, -0.5, -0.5, 0.0, 1.0,
  0.5, -0.5, 0.5, 0.0, 0.0,
  0.5, 0.5, 0.5, 1.0, 0.0,

  -0.5, -0.5, -0.5, 0.0, 1.0,
  0.5, -0.5, -0.5, 1.0, 1.0,
  0.5, -0.5, 0.5, 1.0, 0.0,
  0.5, -0.5, 0.5, 1.0, 0.0,
  -0.5, -0.5, 0.5, 0.0, 0.0,
  -0.5, -0.5, -0.5, 0.0, 1.0,

  -0.5, 0.5, -0.5, 0.0, 1.0,
  0.5, 0.5, -0.5, 1.0, 1.0,
  0.5, 0.5, 0.5, 1.0, 0.0,
  0.5, 0.5, 0.5, 1.0, 0.0,
  -0.5, 0.5, 0.5, 0.0, 0.0,
  -0.5, 0.5, -0.5, 0.0, 1.0,
)
# world space positions of our cubes
cube_positions = [
  Geode::Vector3[0.0, 0.0, 0.0],
  Geode::Vector3[2.0, 5.0, -15.0],
  Geode::Vector3[-1.5, -2.2, -2.5],
  Geode::Vector3[-3.8, -2.0, -12.3],
  Geode::Vector3[2.4, -0.4, -3.5],
  Geode::Vector3[-1.7, 3.0, -7.5],
  Geode::Vector3[1.3, -2.0, -2.5],
  Geode::Vector3[1.5, 2.0, -2.5],
  Geode::Vector3[1.5, 0.2, -1.5],
  Geode::Vector3[-1.3, 1.0, -1.5],
]

vao = context.generate_vertex_array
vbo = context.generate_buffer

vao.bind

context.buffers.array.bind(vbo)
context.buffers.array.initialize_data(vertices, :static_draw)

# position attribute
attribute = context.attributes[0]
attribute.specify_pointer(3, :float32, false, 5 * sizeof(Float32), 0)
attribute.enable
# texture coord attribute
attribute = context.attributes[1]
attribute.specify_pointer(2, :float32, false, 5 * sizeof(Float32), 3_i64 * sizeof(Float32))
attribute.enable

# load and create a texture
# -------------------------

# texture 1
# ---------
texture_1 = context.generate_texture
texture_2d = context.textures.texture_2d
texture_1.bind(texture_2d)
# set the texture wrapping parameters
texture_2d.wrap_s = :repeat
texture_2d.wrap_t = :repeat
# set texture filtering parameters
texture_2d.min_filter = :linear
texture_2d.mag_filter = :linear
# load image, create texture and generate mipmaps
LibSTBImage.set_flip_vertically_on_load(1) # tell stb_image.h to flip loaded texture's on the y-axis.
data = LibSTBImage.load("resources/textures/container.jpg", out width, out height, out channels, 0)
if data
  texture_2d.update_2d(width, height, :rgb, :rgb, :uint8, data)
  texture_2d.generate_mipmap
else
  puts "Failed to load texture"
end
LibSTBImage.image_free(data)
# texture 2
# ---------
texture_2 = context.generate_texture
texture_2.bind(texture_2d)
# set the texture wrapping parameters
texture_2d.wrap_s = :repeat
texture_2d.wrap_t = :repeat
# set texture filtering parameters
texture_2d.min_filter = :linear
texture_2d.mag_filter = :linear
# load image, create texture and generate mipmaps
data = LibSTBImage.load("resources/textures/awesomeface.png", pointerof(width), pointerof(height), pointerof(channels), 0)
if data
  texture_2d.update_2d(width, height, :rgba, :rgba, :uint8, data)
  texture_2d.generate_mipmap
else
  puts "Failed to load texture"
end
LibSTBImage.image_free(data)

# tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
# -------------------------------------------------------------------------------------------
our_shader.use
our_shader.set_int("texture1", 0)
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
  context.clear(Gloop::ClearMask.flags(Color, Depth))

  # bind textures on corresponding texture units
  context.textures.unit = 0
  texture_1.bind(texture_2d)
  context.textures.unit = 1
  texture_2.bind(texture_2d)

  # create transformations
  projection = Geode::Matrix4(Float64).perspective(Geode::Degrees.new(45), SCR_WIDTH / SCR_HEIGHT, 0.1, 100.0)
  projection = projection.map(&.to_f32)
  view = Geode::Matrix4(Float64).translate(0, 0, -3)
  view = view.map(&.to_f32)
  # pass transformation matrices to the shader
  our_shader.set_mat4("projection", projection) # note: currently we set the projection matrix each frame, but since the projection matrix rarely changes it's often best practice to set it outside the main loop only once.
  our_shader.set_mat4("view", view)

  # render boxes
  vao.bind
  cube_positions.each_with_index do |pos, i|
    # calculate the model matrix for each object and pass it to shader before drawing
    model = Geode::Matrix4(Float64).translate(*pos.tuple)
    angle = 20.0 * i
    model = model.rotate(Geode::Radians.new(angle), Geode::Vector3[1.0, 0.3, 0.5])
    model = model.map(&.to_f32)
    our_shader.set_mat4("model", model)

    context.draw_arrays(:triangles, 0, 36)
  end

  # glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
  # -------------------------------------------------------------------------------
  LibGLFW.swap_buffers(window)
  LibGLFW.poll_events
end

# optional: de-allocate all resources once they've outlived their purpose:
# ------------------------------------------------------------------------
vao.delete
vbo.delete

# glfw: terminate, clearing all previously allocated GLFW resources.
# ------------------------------------------------------------------
LibGLFW.terminate
