require "../spec_helper"

Spectator.describe Gloop::Buffers do
  subject(buffers) { described_class.new(context) }

  describe "#array" do
    subject { buffers.array }

    it "retrieves a binding target for array buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::Array)
    end
  end

  describe "#element_array" do
    subject { buffers.element_array }

    it "retrieves a binding target for element array buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::ElementArray)
    end
  end

  describe "#pixel_pack" do
    subject { buffers.pixel_pack }

    it "retrieves a binding target for pixel pack buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::PixelPack)
    end
  end

  describe "#pixel_unpack" do
    subject { buffers.pixel_unpack }

    it "retrieves a binding target for pixel unpack buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::PixelUnpack)
    end
  end

  describe "#transform_feedback" do
    subject { buffers.transform_feedback }

    it "retrieves a binding target for transform feedback buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::TransformFeedback)
    end
  end

  describe "#texture" do
    subject { buffers.texture }

    it "retrieves a binding target for texture buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::Texture)
    end
  end

  describe "#copy_read" do
    subject { buffers.copy_read }

    it "retrieves a binding target for read buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::CopyRead)
    end
  end

  describe "#copy_write" do
    subject { buffers.copy_write }

    it "retrieves a binding target for write buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::CopyWrite)
    end
  end

  describe "#uniform" do
    subject { buffers.uniform }

    it "retrieves a binding target for uniform buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::Uniform)
    end
  end

  describe "#draw_indirect" do
    subject { buffers.draw_indirect }

    it "retrieves a binding target for indirect draw buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::DrawIndirect)
    end
  end

  describe "#atomic_counter" do
    subject { buffers.atomic_counter }

    it "retrieves a binding target for atomic counter buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::AtomicCounter)
    end
  end

  describe "#dispatch_indirect" do
    subject { buffers.dispatch_indirect }

    it "retrieves a binding target for indirect dispatch buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::DispatchIndirect)
    end
  end

  describe "#shader_storage" do
    subject { buffers.shader_storage }

    it "retrieves a binding target for shader storage buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::ShaderStorage)
    end
  end

  describe "#query" do
    subject { buffers.query }

    it "retrieves a binding target for query buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::Query)
    end
  end

  describe "#parameter" do
    subject { buffers.parameter }

    it "retrieves a binding target for parameter buffers" do
      expect(&.target).to eq(Gloop::Buffer::Target::Parameter)
    end
  end

  describe "#[]" do
    it "returns a binding target for the specified target" do
      binding = buffers[:array]
      expect(binding.target).to eq(Gloop::Buffer::Target::Array)
    end
  end

  describe "#copy" do
    let(buffer_a) { Gloop::Buffer.generate(context) }
    let(buffer_b) { Gloop::Buffer.generate(context) }
    let(target_a) { buffers.copy_read }
    let(target_b) { buffers.copy_write }

    before_each do
      target_a.bind(buffer_a)
      target_b.bind(buffer_b)
      target_a.data = Bytes[10, 11, 12, 13, 14, 15, 16, 17]
      target_b.data = Bytes[20, 21, 22, 23, 24, 25, 26, 27]
    end

    it "copies data from one buffer to another" do
      buffers.copy(:copy_read, :copy_write, 1, 2, 4)
      expect(target_b.data).to eq(Bytes[20, 21, 11, 12, 13, 14, 26, 27])
    end
  end
end

Spectator.describe Gloop::Context do
  describe "#buffers" do
    subject { context.buffers }

    it "returns a Buffers instance" do
      is_expected.to be_a(Gloop::Buffers)
    end
  end
end
