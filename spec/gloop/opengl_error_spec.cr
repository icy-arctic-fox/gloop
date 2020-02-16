require "../spec_helper"

Spectator.describe "OpenGL error types" do
  let(code) { subject.code }

  describe Gloop::InvalidEnumError do
    specify { expect(code).to be(LibGL::ErrorCode::InvalidEnum) }
  end

  describe Gloop::InvalidValueError do
    specify { expect(code).to be(LibGL::ErrorCode::InvalidValue) }
  end

  describe Gloop::InvalidOperationError do
    specify { expect(code).to be(LibGL::ErrorCode::InvalidOperation) }
  end

  describe Gloop::OutOfMemoryError do
    specify { expect(code).to be(LibGL::ErrorCode::OutOfMemory) }
  end

  describe Gloop::InvalidFramebufferOperationError do
    specify { expect(code).to be(LibGL::ErrorCode::InvalidFramebufferOperation) }
  end

  describe Gloop::StackUnderflowError do
    specify { expect(code).to be(LibGL::ErrorCode::StackUnderflow) }
  end

  describe Gloop::StackOverflowError do
    specify { expect(code).to be(LibGL::ErrorCode::StackOverflow) }
  end
end
