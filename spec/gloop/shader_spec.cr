require "../spec_helper"

Spectator.describe Gloop::Shader do
  let(shader) { Gloop::FragmentShader.create(context) }

  describe ".type_of" do
    subject { described_class.type_of(shader) }

    it "identifies the type of an existing shader" do
      is_expected.to eq(Gloop::Shader::Type::Fragment)
    end
  end

  describe ".exists?" do
    subject { described_class.exists?(shader) }

    context "with a non-existent shader" do
      let(shader) { 0_u32 } # Zero is an invalid shader name.
      it { is_expected.to be_false }
    end

    context "with an existing shader" do
      it { is_expected.to be_true }
    end
  end
end
