require "./draw_command"

module Gloop
  struct DrawElementsCommand < DrawCommand
    # Creates the command.
    def initialize(primitive, start, count, index_type : UInt8.class)
      super(primitive, count)
      @offset = Pointer(Void).new(start * sizeof(UInt8))
      @type = LibGL::DrawElementsType::UnsignedByte
    end

    # Creates the command.
    def initialize(primitive, start, count, index_type : UInt16.class)
      super(primitive, count)
      @offset = Pointer(Void).new(start * sizeof(UInt16))
      @type = LibGL::DrawElementsType::UnsignedShort
    end

    # Creates the command.
    def initialize(primitive, start, count, index_type : UInt32.class)
      super(primitive, count)
      @offset = Pointer(Void).new(start * sizeof(UInt32))
      @type = LibGL::DrawElementsType::UnsignedInt
    end

    # Executes the command.
    def draw
      checked { LibGL.draw_elements(primitive, count, @type, @offset) }
    end
  end
end
