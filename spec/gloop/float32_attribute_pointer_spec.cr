require "../spec_helper"

Spectator.describe Gloop::Float32AttributePointer do
  subject(attribute) { Gloop::Attributes[0] }

  let(vao) { Gloop::VertexArray.create }
  before_each { vao.bind }
  after_each { Gloop::VertexArray.unbind }

  let(buffer) { Gloop::Buffer.mutable(Bytes[0, 1, 2, 3, 4, 5, 6, 7]) }
  before_each { buffer.bind(:array) }

  # Unused definition, should be overridden.
  let!(definition) { described_class.new(0, :uint8, true, 0, 0) }
  before_each { Gloop::Attributes[0] = definition }

  context "generic pointer" do
    let(definition) { described_class.new(3, :int16, true, 24, Pointer(Void).new(32)) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int16)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "generic offset" do
    let(definition) { described_class.new(3, :int16, true, 24, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int16)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Float32 pointer" do
    let(definition) { described_class.new(3, Float32, 24, Pointer(Void).new(32)) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Float32)
        is_expected.to_not be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Float32 offset" do
    let(definition) { described_class.new(3, Float32, 24, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Float32)
        is_expected.to_not be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Float64 pointer" do
    let(definition) { described_class.new(3, Float64, 24, Pointer(Void).new(32)) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Float64)
        is_expected.to_not be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Float64 offset" do
    let(definition) { described_class.new(3, Float64, 24, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Float64)
        is_expected.to_not be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Int8 pointer" do
    let(definition) { described_class.new(3, Int8, true, 24, Pointer(Void).new(32)) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int8)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Int8 offset" do
    let(definition) { described_class.new(3, Int8, true, 24, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int8)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "UInt8 pointer" do
    let(definition) { described_class.new(3, UInt8, true, 24, Pointer(Void).new(32)) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::UInt8)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "UInt8 offset" do
    let(definition) { described_class.new(3, UInt8, true, 24, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::UInt8)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Int16 pointer" do
    let(definition) { described_class.new(3, Int16, true, 24, Pointer(Void).new(32)) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int16)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Int16 offset" do
    let(definition) { described_class.new(3, Int16, true, 24, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int16)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "UInt16 pointer" do
    let(definition) { described_class.new(3, UInt16, true, 24, Pointer(Void).new(32)) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::UInt16)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "UInt16 offset" do
    let(definition) { described_class.new(3, UInt16, true, 24, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::UInt16)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Int32 pointer" do
    let(definition) { described_class.new(3, Int32, true, 24, Pointer(Void).new(32)) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int32)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "Int32 offset" do
    let(definition) { described_class.new(3, Int32, true, 24, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Int32)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "UInt32 pointer" do
    let(definition) { described_class.new(3, UInt32, true, 24, Pointer(Void).new(32)) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::UInt32)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end

  context "UInt32 offset" do
    let(definition) { described_class.new(3, UInt32, true, 24, 32) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::UInt32)
        is_expected.to be_normalized
        expect(&.stride).to eq(24)
        expect(&.buffer_offset).to eq(32)
      end
    end
  end
end
