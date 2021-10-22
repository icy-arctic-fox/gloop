require "../../spec_helper"

Spectator.describe Gloop::VertexArray::Bindings do
  let(vao) { Gloop::VertexArray.create(context) }
  subject(bindings) { described_class.new(context, vao.name) }

  describe "#size" do
    subject { bindings.size }

    it "is the maximum number of bindings" do
      value = uninitialized Int32
      context.gl.get_integer_v(LibGL::GetPName::MaxVertexAttribBindings, pointerof(value))
      is_expected.to eq(value)
    end
  end

  describe "#unsafe_fetch" do
    it "returns an indexed binding" do
      binding = bindings.unsafe_fetch(2)
      expect(binding.index).to eq(2)
    end
  end
end
