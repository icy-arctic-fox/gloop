require "../spec_helper"

Spectator.describe Gloop::Program do
  before_all { init_opengl }
  after_all { terminate_opengl }

  subject(program) { described_class.create }

  describe "#delete" do
    it "deletes a program" do
      subject.delete
      expect(subject.exists?).to be_false
    end
  end

  describe "#exists?" do
    subject { program.exists? }

    context "with a non-existent program" do
      let(program) { described_class.new(0_u32) } # Zero is an invalid program name.
      it { is_expected.to be_false }
    end

    context "with an existing program" do
      it { is_expected.to be_true }
    end
  end

  describe "#info_log" do
    it "contains information after a failed compilation"
  end

  describe "#info_log_size" do
    it "is the size of the info log"
  end

  context "Labelable" do
    it "can be labeled" do
      subject.label = "Test label"
      expect(&.label).to eq("Test label")
    end
  end
end
