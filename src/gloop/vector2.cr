module Gloop
  # Vector with two components.
  struct Vector2(T)
    # Value of the x component.
    property x : T

    # Value of the y component.
    property y : T

    # Creates the vector from components.
    def initialize(@x : T, @y : T)
    end

    # Creates the vector from an existing vector.
    def initialize(vector : Vector2(T))
      @x = vector.x
      @y = vector.y
    end

    # Value of the x component.
    def r
      @x
    end

    # Value of the x component.
    def r=(value)
      @x = value
    end

    # Value of the y component.
    def g
      @y
    end

    # Value of the y component.
    def g=(value)
      @y = value
    end

    # Value of the x component.
    def s
      @x
    end

    # Value of the x component.
    def s=(value)
      @x = value
    end

    # Value of the y component.
    def t
      @y
    end

    # Value of the y component.
    def t=(value)
      @y = value
    end

    # Retrieves the specified component.
    def [](index : Int) : T
      case index
      when 0 then @x
      when 1 then @y
      else
        raise IndexError.new
      end
    end

    # Updates the specified component.
    def []=(index : Int, value : T)
      case index
      when 0 then @x = value
      when 1 then @y = value
      else
        raise IndexError.new
      end
    end

    {% for set in [%i[x y], %i[r g], %i[s t]] %}
    {% for i in set %}
    {% for j in set %}
    # Returns a new vector via swizzling.
    def {{i.id}}{{j.id}} : Vector2(T)
      Vector2.new({{i.id}}, {{j.id}})
    end

    {% if i != j %}
    # Updates the components via swizzling.
    def {{i.id}}{{j.id}}=(vector : Vector2(T))
      self.{{i.id}} = vector.x
      self.{{j.id}} = vector.y
    end
    {% end %}
    {% end %}
    {% end %}
    {% end %}

    # Produces a string containing the vector values.
    def to_s(io)
      io << '('
      io << x
      io << ", "
      io << y
      io << ')'
    end
  end
end
