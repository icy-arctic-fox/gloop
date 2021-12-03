require "../spec_helper"

Spectator.describe "Error handling" do
  let(gl) { context.gl }

  describe "Gloop::ErrorHandling#error_code" do
    subject { gl.error_code }

    context "with no error" do
      before_each do
        # Perform an operation that shouldn't trigger an error.
        value = uninitialized Int32
        gl.get_integer_v(LibGL::GetPName::MajorVersion, pointerof(value), unchecked: true)
      end

      it "returns Error::None" do
        is_expected.to eq(Gloop::Error::None)
      end
    end

    context "with an error" do
      before_each do
        # Perform an operation that should trigger an error.
        bad_pname = LibGL::GetPName.new(0)
        value = uninitialized Int32
        gl.get_integer_v(bad_pname, pointerof(value), unchecked: true)
      end

      it "returns an error" do
        skip_if_error_checking_disabled
        is_expected.to eq(Gloop::Error::InvalidEnum)
      end
    end
  end

  describe "Gloop::ErorHandling#error" do
    subject { gl.error }

    context "with no error" do
      before_each do
        # Clear any existing errors.
        gl.error
        # Perform an operation that shouldn't trigger an error.
        value = uninitialized Int32
        gl.get_integer_v(LibGL::GetPName::MajorVersion, pointerof(value), unchecked: true)
      end

      it "returns nil" do
        is_expected.to be_nil
      end
    end

    context "with an error" do
      before_each do
        # Perform an operation that should trigger an error.
        bad_pname = LibGL::GetPName.new(0)
        value = uninitialized Int32
        gl.get_integer_v(bad_pname, pointerof(value), unchecked: true)
      end

      it "returns an error" do
        is_expected.to be_a(Gloop::InvalidEnumError)
      end
    end
  end

  describe "#error!" do
    context "with no error" do
      before_each do
        # Perform an operation that shouldn't trigger an error.
        value = uninitialized Int32
        gl.get_integer_v(LibGL::GetPName::MajorVersion, pointerof(value), unchecked: true)
      end

      it "doesn't raise" do
        expect { gl.error! }.to_not raise_error
      end
    end

    context "with an error" do
      before_each do
        # Perform an operation that should trigger an error.
        bad_pname = LibGL::GetPName.new(0)
        value = uninitialized Int32
        gl.get_integer_v(bad_pname, pointerof(value), unchecked: true)
      end

      it "raises an error" do
        expect { gl.error! }.to raise_error(Gloop::InvalidEnumError)
      end
    end
  end
end
