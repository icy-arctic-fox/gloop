require "../spec_helper"

Spectator.describe Gloop::Context do
  before_all { init_opengl }
  after_all { terminate_opengl }

  describe "#major_version" do
    specify { expect(&.major_version).to eq(4) }
  end

  describe "#minor_version" do
    specify { expect(&.minor_version).to eq(6) }
  end

  describe "#version" do
    specify { expect(&.version.to_s).to eq("4.6") }
  end

  describe "#profile" do
    specify { expect(&.profile).to eq(Gloop::Context::Profile::Core) }
  end
end
