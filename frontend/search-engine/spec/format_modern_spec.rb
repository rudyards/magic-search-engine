describe "Formats - Modern" do
  include_context "db"

  let(:regular_sets) { db.sets.values.select{|s|
    s.type == "core" or s.type == "expansion" or s.name =~ /Welcome Deck/
  }.to_set }

  describe "Modern legal sets" do
    let(:start_date) { db.sets["8e"].release_date }
    let(:expected) { regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set }
    let(:actual) { FormatModern.new.included_sets }
    it { expected.should eq actual }
  end

  it "modern" do
    assert_block_composition "modern", "rix", ["8e", "mi", "ds", "5dn", "chk", "bok", "sok", "9e", "rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt", "shm", "eve", "ala", "cfx", "arb", "m10", "zen", "wwk", "roe", "m11", "som", "mbs", "nph", "m12", "isd", "dka", "avr", "m13", "rtr", "gtc", "dgm", "m14", "ths", "bng", "jou", "m15", "ktk", "frf", "dtk", "ori", "bfz", "ogw", "soi", "emn", "kld", "aer", "akh", "w17", "hou", "xln", "rix"],
      "Ancient Den" => "banned",
      "Birthing Pod" => "banned",
      "Blazing Shoal" => "banned",
      "Bloodbraid Elf" => "banned",
      "Chrome Mox" => "banned",
      "Cloudpost" => "banned",
      "Dark Depths" => "banned",
      "Deathrite Shaman" => "banned",
      "Dig Through Time" => "banned",
      "Dread Return" => "banned",
      "Eye of Ugin" => "banned",
      "Gitaxian Probe" => "banned",
      "Glimpse of Nature" => "banned",
      "Golgari Grave-Troll" => "banned",
      "Great Furnace" => "banned",
      "Green Sun's Zenith" => "banned",
      "Hypergenesis" => "banned",
      "Jace, the Mind Sculptor" => "banned",
      "Mental Misstep" => "banned",
      "Ponder" => "banned",
      "Preordain" => "banned",
      "Punishing Fire" => "banned",
      "Rite of Flame" => "banned",
      "Seat of the Synod" => "banned",
      "Second Sunrise" => "banned",
      "Seething Song" => "banned",
      "Sensei's Divining Top" => "banned",
      "Skullclamp" => "banned",
      "Splinter Twin" => "banned",
      "Stoneforge Mystic" => "banned",
      "Summer Bloom" => "banned",
      "Treasure Cruise" => "banned",
      "Tree of Tales" => "banned",
      "Umezawa's Jitte" => "banned",
      "Vault of Whispers" => "banned"
    assert_legality "modern", "avr", "Rancor", nil
    assert_legality "modern", "m13", "Rancor", "legal"
    assert_legality "modern", "m12", "Wild Nacatl", "legal"
    assert_legality "modern", "m13", "Wild Nacatl", "banned"
    assert_legality "modern", "bng", "Wild Nacatl", "legal"
    assert_legality "modern", "m13", "Lightning Bolt", "legal"
  end
end
