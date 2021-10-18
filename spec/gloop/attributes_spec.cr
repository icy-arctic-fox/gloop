require "../spec_helper"

Spectator.describe Gloop::Attributes do
  subject(attributes) { described_class.new(context) }
  let(vao) { Gloop::VertexArray.create(context) }

  before_each { vao.bind }

  describe "#size" do
    subject { attributes.size }

    it "is the maximum number of attributes" do
      value = uninitialized Int32
      context.gl.get_integer_v(LibGL::GetPName::MaxVertexAttribs, pointerof(value))
      is_expected.to eq(value)
    end
  end

  describe "#unsafe_fetch" do
    it "returns an indexed attribute" do
      attribute = attributes.unsafe_fetch(2)
      expect(attribute.index).to eq(2)
    end
  end
end
