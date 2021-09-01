require "../../spec_helper"

Spectator.describe Gloop::VertexArray::Bindings do
  let(vao) { Gloop::VertexArray.create }
  subject(bindings) { vao.bindings }

  def max_bindings
    LibGL.get_integer_v(LibGL::GetPName::MaxVertexAttribBindings, out max)
    max
  end

  describe ".max" do
    subject { described_class.max }

    it "is the maximum number of bindings" do
      is_expected.to eq(max_bindings)
    end
  end

  describe "#size" do
    subject { super.size }

    it "is the maximum number of bindings" do
      is_expected.to eq(max_bindings)
    end
  end

  describe "#unsafe_fetch" do
    let(index) { 0 }
    subject(binding) { bindings.unsafe_fetch(index) }

    it "returns a reference to a binding" do
      expect(&.index).to eq(index)
    end
  end
end
