require "../../spec_helper"

Spectator.describe Gloop::VertexArray::CurrentBindings do
  subject(bindings) { described_class.new(context) }

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

Spectator.describe Gloop::Context do
  subject { context }

  describe "#bindings" do
    specify { expect(&.bindings).to be_an(Enumerable(Gloop::VertexArray::CurrentBinding)) }
  end
end
