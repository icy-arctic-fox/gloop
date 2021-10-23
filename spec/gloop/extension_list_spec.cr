require "../spec_helper"

Spectator.describe Gloop::ExtensionList do
  subject { described_class.new(context) }

  describe "#size" do
    subject { super.size }

    it "equals the number of extensions" do
      count = uninitialized Int32
      context.gl.get_integer_v(LibGL::GetPName::NumExtensions, pointerof(count))
      is_expected.to eq(count)
    end
  end

  describe "#unsafe_fetch" do
    it "can retrieve an extension" do
      skip "No extensions" if subject.empty?

      ptr = context.gl.get_string_i(LibGL::StringName::Extensions, 0_u32)
      name = String.new(ptr)
      extension = subject.unsafe_fetch(0)
      expect(extension.name).to eq(name)
    end
  end
end

Spectator.describe Gloop::Context do
  subject { context }

  describe "#extensions" do
    specify { expect(&.extensions).to be_an(Enumerable(Gloop::Extension)) }
  end
end
