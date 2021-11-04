require "../spec_helper"

Spectator.describe Gloop::Uniforms do
  subject(uniforms) { Gloop::Uniforms.new(context) }

  describe "#[]" do
    it "returns a uniform with the specified location" do
      uniform = uniforms[5]
      expect(uniform.location).to eq(5)
    end
  end
end

Spectator.describe Gloop::Context do
  describe "#uniforms" do
    subject { context.uniforms }

    it "returns a set of uniforms" do
      is_expected.to be_a(Gloop::Uniforms)
    end
  end
end
