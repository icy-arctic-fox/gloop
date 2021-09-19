require "../spec_helper"

Spectator.describe Gloop::ShadingLanguageVersionList do
  subject { described_class.new(context) }

  describe "#size" do
    subject { super.size }

    it "equals the number of supported versions" do
      pname = LibGL::GetPName.new(LibGL::NUM_SHADING_LANGUAGE_VERSIONS.to_u32!)
      count = uninitialized Int32
      context.gl.get_integer_v(pname, pointerof(count))
      is_expected.to eq(count)
    end
  end

  describe "#unsafe_fetch" do
    it "can retrieve a version" do
      skip "No versions" if subject.empty?

      ptr = context.gl.get_string_i(LibGL::StringName::ShadingLanguageVersion, 0_u32)
      expected = String.new(ptr)
      actual = subject.unsafe_fetch(0)
      expect(actual).to eq(expected)
    end
  end
end
