describe "Opening packs smoke test" do
  include_context "db"
  let(:pack_factory) { PackFactory.new(db) }

  it "Opening packs should return something" do
    db.sets.each do |set_code, set|
      pack = pack_factory.for(set_code)
      next unless pack
      cards = pack.open
      cards.should be_a(Array)
      cards.each do |card|
        card.should be_a(PhysicalCard)
      end
    end
  end
end
