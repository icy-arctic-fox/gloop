require "../spec_helper"

Spectator.describe Gloop::Float64AttributePointer do
  subject(attribute) { Gloop::Attributes[0] }

  let(vao) { Gloop::VertexArray.create }
  before_each { vao.bind }
  after_each { Gloop::VertexArray.unbind }

  let(buffer) { Gloop::Buffer.mutable(Bytes[0, 1, 2, 3, 4, 5, 6, 7]) }
  before_each { buffer.bind(:array) }

  # Unused definition, should be overridden.
  let!(definition) { described_class.new(0, :float64, 0, 0) }
  before_each { Gloop::Attributes[0] = definition }

  context "generic" do
    let(definition) { described_class.new(3, :float64, 32, 64) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Float64)
        expect(&.stride).to eq(32)
        expect(&.buffer_offset).to eq(64)
      end
    end
  end

  context "Float64" do
    let(definition) { described_class.new(3, Float64, 32, 64) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Float64)
        expect(&.stride).to eq(32)
        expect(&.buffer_offset).to eq(64)
      end
    end
  end

  context "simple" do
    let(definition) { described_class.new(3, 32, 64) }

    it "has the expected values" do
      aggregate_failures "attribute parameters" do
        expect(&.size).to eq(3)
        expect(&.type).to eq(Gloop::Attribute::Type::Float64)
        expect(&.stride).to eq(32)
        expect(&.buffer_offset).to eq(64)
      end
    end
  end
end
