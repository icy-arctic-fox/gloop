require "../spec_helper"

Spectator.describe Gloop do
  before_all { init_opengl }
  after_all { terminate_opengl }

  describe ".error_code" do
    subject { Gloop.error_code }

    context "with no error" do
      before_each do
        # Perform an operation that shouldn't trigger an error.
        LibGL.get_integer_v(LibGL::GetPName::MajorVersion, out value)
      end

      it "returns Error::None" do
        is_expected.to eq(Gloop::Error::None)
      end
    end

    context "with an error" do
      before_each do
        # Perform an operation that should trigger an error.
        bad_pname = LibGL::GetPName.new(0)
        LibGL.get_integer_v(bad_pname, out value)
      end

      it "returns an error" do
        is_expected.to eq(Gloop::Error::InvalidEnum)
      end
    end
  end

  describe ".error" do
    subject { Gloop.error }

    context "with no error" do
      before_each do
        # Perform an operation that shouldn't trigger an error.
        LibGL.get_integer_v(LibGL::GetPName::MajorVersion, out value)
      end

      it "returns nil" do
        is_expected.to be_nil
      end
    end

    context "with an error" do
      before_each do
        # Perform an operation that should trigger an error.
        bad_pname = LibGL::GetPName.new(0)
        LibGL.get_integer_v(bad_pname, out value)
      end

      it "returns an error" do
        is_expected.to be_a(Gloop::InvalidEnumError)
      end
    end
  end

  describe ".error!" do
    context "with no error" do
      before_each do
        # Perform an operation that shouldn't trigger an error.
        LibGL.get_integer_v(LibGL::GetPName::MajorVersion, out value)
      end

      it "doesn't raise" do
        expect { Gloop.error! }.to_not raise_error
      end
    end

    context "with an error" do
      before_each do
        # Perform an operation that should trigger an error.
        bad_pname = LibGL::GetPName.new(0)
        LibGL.get_integer_v(bad_pname, out value)
      end

      it "raises an error" do
        expect { Gloop.error! }.to raise_error(Gloop::InvalidEnumError)
      end
    end
  end
end
