require "../spec_helper"

Spectator.describe Gloop::ExtensionList do
  before_all { init_opengl }
  after_all { terminate_opengl }

  describe "#size" do
    subject { super.size }

    it "equals the number of extensions" do
      LibGL.get_integer_v(LibGL::GetPName::NumExtensions, out extension_count)
      is_expected.to eq(extension_count)
    end
  end

  describe "#unsafe_fetch" do
    it "can retrieve an extension" do
      return if subject.empty? # Skip test if there are no extensions.

      extension_name = LibGL.get_string_i(LibGL::StringName::Extensions, 0)
      extension_name = String.new(extension_name)
      extension = subject.unsafe_fetch(0)
      expect(extension.name).to eq(extension_name)
    end
  end
end
