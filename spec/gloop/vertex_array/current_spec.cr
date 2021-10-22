require "../../spec_helper"

Spectator.describe Gloop::VertexArray::Current do
  subject(current) { described_class.new(context) }
  let(vao) { Gloop::VertexArray.create(context) }

  before_each { vao.bind }

  describe "#bound?" do
    subject { current.bound? }

    context "when a vertex array is bound" do
      before_each { vao.bind }

      it "is true" do
        is_expected.to be_true
      end
    end

    context "when a vertex array isn't bound" do
      before_each { current.unbind }

      it "is false" do
        is_expected.to be_false
      end
    end
  end

  describe "#unbind" do
    it "unbinds a vertex array" do
      expect(&.unbind).to change(&.bound?).from(true).to(false)
    end
  end

  describe "#attributes" do
    subject { current.attributes }

    it "is a collection of attributes" do
      is_expected.to be_an(Enumerable(Gloop::Attribute))
    end
  end

  describe "#bind_vertex_buffer" do
    let(slot) { 0_u32 }
    let(buffer) { Gloop::Buffer.create(context) }
    let(attribute) { Gloop::Attribute.new(context, 0) }
    let(binding) { Gloop::VertexArray::CurrentBinding.new(context, slot) }

    before_each do
      attribute.enable
      attribute.float32_format(2, :float32, false, 24)
    end

    it "sets the stride and offset" do
      current.bind_attribute(attribute, slot)
      current.bind_vertex_buffer(buffer, slot, 64, 256)
      expect(binding.offset).to eq(64)
      expect(binding.stride).to eq(256)
    end
  end

  describe "#bind_attribute" do
    let(slot) { 0_u32 }
    let(attribute) { Gloop::Attribute.new(context, 0) }
    let(binding) { Gloop::VertexArray::CurrentBinding.new(context, slot) }

    before_each do
      attribute.enable
      attribute.float32_format(2, :float32, false, 24)
    end

    it "sets the stride" do
      current.bind_attribute(attribute, slot)
      expect(binding.stride).to eq(16) # 2 x sizeof(Float32)
    end
  end

  describe "#bindings" do
    subject { current.bindings }

    it "is a collection of binding slots" do
      is_expected.to be_an(Enumerable(Gloop::VertexArray::CurrentBinding))
    end
  end
end
