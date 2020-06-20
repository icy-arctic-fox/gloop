module Gloop
  # Vector with three components.
  struct Vector3(T)
    # Value of the x component.
    property x : T

    # Value of the y component.
    property y : T

    # Value of the z component.
    property z : T

    # Creates the vector from components.
    def initialize(@x : T, @y : T, @z : T)
    end

    # Creates the vector from an existing vector.
    def initialize(vector : Vector3(T))
      @x = vector.x
      @y = vector.y
      @z = vector.z
    end

    # Value of the x component.
    def r : T
      @x
    end

    # Value of the x component.
    def r=(value : T)
      @x = value
    end

    # Value of the y component.
    def g : T
      @y
    end

    # Value of the y component.
    def g=(value : T)
      @y = value
    end

    # Value of the z component.
    def b : T
      @z
    end

    # Value of the z component.
    def b=(value : T)
      @z = value
    end

    # Value of the x component.
    def s : T
      @x
    end

    # Value of the x component.
    def s=(value : T)
      @x = value
    end

    # Value of the y component.
    def t : T
      @y
    end

    # Value of the y component.
    def t=(value : T)
      @y = value
    end

    # Value of the z component.
    def p : T
      @z
    end

    # Value of the z component.
    def p=(value : T)
      @z = value
    end

    # Retrieves the specified component.
    def [](index : Int) : T
      case index
      when 0 then @x
      when 1 then @y
      when 2 then @z
      else
        raise IndexError.new
      end
    end

    # Updates the specified component.
    def []=(index : Int, value : T)
      case index
      when 0 then @x = value
      when 1 then @y = value
      when 2 then @z = value
      else
        raise IndexError.new
      end
    end

    {% for set in [%i[x y z], %i[r g b], %i[s t p]] %}
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

    {% for k in set %}
    # Returns a new vector via swizzling.
    def {{i.id}}{{j.id}}{{k.id}} : Vector3(T)
      Vector3.new({{i.id}}, {{j.id}}, {{k.id}})
    end

    {% if i != j && j != k && i != k %}
    # Updates the components via swizzling.
    def {{i.id}}{{j.id}}{{k.id}}=(vector : Vector3(T))
      self.{{i.id}} = vector.x
      self.{{j.id}} = vector.y
      self.{{k.id}} = vector.z
    end
    {% end %}
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
      io << ", "
      io << z
      io << ')'
    end
  end
end
