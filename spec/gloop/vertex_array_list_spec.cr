require "../spec_helper"

Spectator.describe Gloop::VertexArrayList do
  subject(list) { Gloop::VertexArray.create(context, 3) }

  it "holds vertex arrays" do
    is_expected.to be_an(Indexable(Gloop::VertexArray))
    expect(&.size).to eq(3)
    aggregate_failures "vertex arrays" do
      expect(list[0]).to be_a(Gloop::VertexArray)
      expect(list[1]).to be_a(Gloop::VertexArray)
      expect(list[2]).to be_a(Gloop::VertexArray)
    end
  end

  describe "#delete" do
    it "deletes all vertex arrays" do
      list.delete
      aggregate_failures "vertex arrays" do
        list.each do |vertex_array|
          expect(vertex_array.exists?).to be_false
        end
      end
    end
  end
end
