require "../spec_helper"

Spectator.describe Gloop::Buffers do
  describe "#[]" do
    it "retrieves a binding target" do
      binding = Gloop::Buffers[:element_array]
      expect(binding.target).to eq(Gloop::Buffer::Target::ElementArray)
    end
  end
end
