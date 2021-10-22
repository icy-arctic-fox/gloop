require "../../spec_helper"

Spectator.describe Gloop::VertexArray::Binding do
  subject(binding) { described_class.new(context, vao.name, slot) }
  let(slot) { 0_u32 }
  let(vao) { Gloop::VertexArray.create(context) }
  let(attribute) { Gloop::VertexArray::Attribute.new(context, vao.name, 2) }
  let(buffer) { Gloop::Buffer.create(context) }

  before_each { vao.bind }
  before_each { attribute.float32_format(2, :float32, false, 24) }

  it "sets the index" do
    expect(&.index).to eq(slot)
  end

  describe "#bind_vertex_buffer" do
    it "sets the offset and stride" do
      binding.bind_vertex_buffer(buffer, 64, 128)
      expect(&.offset).to eq(64)
      expect(&.stride).to eq(128)
    end
  end

  describe "#attribute=" do
    it "sets the stride" do
      binding.attribute = attribute
      expect(&.stride).to eq(16) # 2 x Float32
    end
  end

  describe "#divisor=" do
    it "sets the divisor" do
      binding.divisor = 2
      expect(&.divisor).to eq(2)
    end
  end
end
