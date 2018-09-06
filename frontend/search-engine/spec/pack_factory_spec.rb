describe PackFactory do
  include_context "db"
  let(:factory) { PackFactory.new(db) }

  it "Only sets of appropriate types have sealed packs" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      # Indexer responsibility to set this flag
      if set.has_boosters?
        pack = factory.for(set_code)
        if pack
          pack.should be_a(Pack), "#{set_pp} should have packs"
        else
          # TODO: pending
        end
      else
        pack.should eq(nil), "#{set_pp} should not have packs"
      end
    end
  end

  # There's no guarantee they'll always have them,
  # but it's worth checking exceptions manually
  context "Standard legal sets since Origins generally have non-booster cards" do
    let(:start_date) { db.sets["ori"].release_date }
    let(:regular_sets) { db.sets.values.select{|s|
      s.type == "core" or s.type == "expansion"
    }.to_set }
    let(:expected) {
      regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set - %W[emn soi]
    }
    let(:sets_with_boosters) { db.sets.values.select(&:has_boosters?) }
    let(:sets_with_nonbooster_cards) {
      sets_with_boosters.select{|set| set.printings.any?(&:exclude_from_boosters?) }.map(&:code)
    }
    it do
      sets_with_nonbooster_cards.should match_array expected
    end
  end

  it "Every card can appear in a pack" do
    db.sets.each do |set_code, set|
      # Some sets don't follow these rules
      # They should have own tests
      next if %W[dgm uh jou frf ts cns].include?(set_code)
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = factory.for(set_code)
      next unless pack
      pack.nonfoil_cards.should match_array(set.physical_cards_in_boosters),
        "All cards in #{set_pp} should be possible in its packs as nonfoil"
    end
  end

  it "Every set with foils has all cards available as foils" do
    db.sets.each do |set_code, set|
      # Some sets don't follow these rules
      # They should have own tests
      next if %W[ts csn].include?(set_code)
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = factory.for(set_code)
      next unless pack
      next unless pack.has_foils?
      actual_cards = pack.foil_cards.select{|c| c.set.type != "masterpiece"}
      expected_cards = set.physical_cards_in_boosters(true)
      actual_cards.should match_array(expected_cards),
        "All cards in #{set_pp} should be possible in its packs as foil"
    end
  end

  context "Dragon's Maze" do
    let(:pack) { factory.for("dgm") }
    let(:ev) { pack.expected_values }
    let(:maze_end) { physical_card("e:dgm maze end", foil) }
    let(:guildgate) { physical_card("e:dgm azorius guildgate", foil) }
    let(:common) { physical_card("e:dgm azorius cluestone", foil) }
    let(:uncommon) { physical_card("e:dgm alive // well", foil) }
    let(:rare) { physical_card("e:dgm advent of the wurm", foil) }
    let(:mythic) { physical_card("e:dgm progenitor mimic", foil) }
    let(:shockland) { physical_card("e:rtr temple garden", foil) }

    context "normal" do
      let(:foil) { false }

      it do
        ev[guildgate].should eq Rational(23, 242)
        ev[maze_end].should eq Rational(2, 242)
        ev[shockland].should eq Rational(1, 242)
        # 9.75 commons per pack, since 25% of packs have foil instead
        ev[common].should eq Rational(975, 100) * Rational(1, 60)
        ev[uncommon].should eq Rational(3, 40)
        ev[rare].should eq Rational(1, 40)
        ev[mythic].should eq Rational(1, 80)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        # Definitely no shocklands
        ev[shockland].should eq 0

        # This is all pure guesswork
        # - base rarity rates on foils are guesses
        # - assumption that foiling treats maze's end and guildgates like regular cards is a guess
        # Perhaps it's wrong, and we should instead assume land slot works like basic-land foils?
        ev[guildgate].should eq Rational(1,4) * Rational(5,8) * Rational(1,70)
        ev[common].should eq Rational(1,4) * Rational(5,8) * Rational(1,70)
        ev[uncommon].should eq Rational(1,4) * Rational(2,8) * Rational(1,40)
        ev[rare].should eq Rational(1,4) * Rational(1,8) * Rational(2,81)
        ev[mythic].should eq Rational(1,4) * Rational(1,8) * Rational(1,81)
        ev[maze_end].should eq Rational(1,4) * Rational(1,8) * Rational(1,81)
      end
    end
  end

  context "Unhinged" do
    let(:pack) { factory.for("uh") }
    let(:ev) { pack.expected_values }
    let(:basic) { physical_card("e:uh forest", foil) }
    let(:common) { physical_card("e:uh awol", foil) }
    let(:uncommon) { physical_card("e:uh cheatyface", foil) }
    let(:rare) { physical_card("e:uh ambiguity", foil) }
    let(:super_secret_tech) { physical_card("e:uh super secret tech", foil) }

    context "normal" do
      let(:foil) { false }
      it do
        ev[basic].should eq Rational(1,5)
        ev[common].should eq Rational(975,100) * Rational(1,55)
        ev[uncommon].should eq Rational(3,40)
        ev[rare].should eq Rational(1,40)
        ev[super_secret_tech].should eq 0
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(1,4) * Rational(1,8) * Rational(1,5)
        ev[common].should eq Rational(1,4) * Rational(4,8) * Rational(1,55)
        ev[uncommon].should eq Rational(1,4) * Rational(2,8) * Rational(1,40)
        ev[rare].should eq Rational(1,4) * Rational(1,8) * Rational(1,41)
        ev[super_secret_tech].should eq Rational(1,4) * Rational(1,8) * Rational(1,41)
      end
    end
  end

  context "Fate Reforged" do
    let(:pack) { factory.for("frf") }
    let(:ev) { pack.expected_values }
    let(:basic) { physical_card("e:frf forest", foil) }
    let(:gainland) { physical_card("e:frf blossoming sands", foil) }
    let(:common) { physical_card("e:frf abzan runemark", foil) }
    let(:uncommon) { physical_card("e:frf break through the line", foil) }
    let(:rare) { physical_card("e:frf atarka world render", foil) }
    let(:mythic) { physical_card("e:frf soulfire grand master", foil) }
    let(:fetchland) { physical_card("e:ktk flooded strand", foil) }

    context "normal" do
      let(:foil) { false }

      it do
        # Basics only in fat packs - also 2 of each type
        ev[basic].should eq 0
        ev[gainland].should eq Rational(23, 240)
        # 2/121 - change of each shock in KTK
        # This is supposed to be half, 120 has a bit easier math
        ev[fetchland].should eq Rational(1, 120)
        ev[common].should eq Rational(975, 100) * Rational(1, 60)
        ev[uncommon].should eq Rational(3, 60)
        ev[rare].should eq Rational(2, 80)
        ev[mythic].should eq Rational(1, 80)
      end
    end

    context "foil" do
      let(:foil) { true }

      # So many questionable assumptions go into this
      it do
        # Definitely no fetchlands
        ev[fetchland].should eq 0
        ev[basic].should eq Rational(1,4) * Rational(1,8) * Rational(1,10)
        ev[gainland].should eq Rational(1,4) * Rational(4,8) * Rational(1,70)
        ev[common].should eq Rational(1,4) * Rational(4,8) * Rational(1,70)
        ev[uncommon].should eq Rational(1,4) * Rational(2,8) * Rational(1,60)
        ev[rare].should eq Rational(1,4) * Rational(1,8) * Rational(2,80)
        ev[mythic].should eq Rational(1,4) * Rational(1,8) * Rational(1,80)
      end
    end
  end

  context "Journey Into Nyx" do
    let(:pack) { factory.for("jou") }
    let(:ev) { pack.expected_values }
    let(:old_gods) { db.search("t:god e:ths,bng").printings.map{|c| PhysicalCard.for(c) } }
    let(:new_gods) { db.search("t:god e:jou").printings.map{|c| PhysicalCard.for(c) } }
    let(:rate) { 4320 }

    # Not the clearest test as they appear all together
    it "God Packs" do
      old_gods.each do |god|
        ev[god].should eq Rational(1, rate)
      end
      new_gods.each do |god|
        ev[god].should eq Rational(1, rate) + Rational(1, 80) * Rational(rate - 1, rate)
      end
    end
  end

  context "Innistrad" do
    let(:pack) { factory.for("isd") }
    let(:ev) { pack.expected_values }
    let(:dfc_mythic) { physical_card("e:isd Garruk Relentless") }
    let(:sfc_mythic) { physical_card("e:isd Army of the Damned") }
    let(:foil_dfc_mythic) { physical_card("e:isd Garruk Relentless", true) }
    let(:foil_sfc_mythic) { physical_card("e:isd Army of the Damned", true) }

    it do
      ev[dfc_mythic].should eq Rational(1, 121)
      ev[sfc_mythic].should eq Rational(1, 121)
      ev[foil_dfc_mythic].should eq Rational(1, 4288)
      ev[foil_sfc_mythic].should eq Rational(1, 4288)
    end
  end

  context "Dark Ascension" do
    let(:pack) { factory.for("dka") }
    let(:ev) { pack.expected_values }
    let(:dfc_mythic) { physical_card("e:dka Elbrus, the Binding Blade") }
    let(:sfc_mythic) { physical_card("e:dka Beguiler of Wills") }
    let(:foil_dfc_mythic) { physical_card("e:dka Elbrus, the Binding Blade", true) }
    let(:foil_sfc_mythic) { physical_card("e:dka Beguiler of Wills", true) }

    it do
      ev[dfc_mythic].should eq Rational(1, 80)
      ev[sfc_mythic].should eq Rational(1, 80)
      ev[foil_dfc_mythic].should eq Rational(1, 2816)
      ev[foil_sfc_mythic].should eq Rational(1, 2816)
    end
  end

  context "Time Spiral" do
    let(:pack) { factory.for("ts") }
    let(:ev) { pack.expected_values }
    let(:basic) { physical_card("e:ts forest", foil) }
    let(:common) { physical_card("e:ts bonesplitter sliver", foil) }
    let(:uncommon) { physical_card("e:ts dread return", foil) }
    let(:rare) { physical_card("e:ts academy ruins", foil) }
    let(:timeshifted) { physical_card("e:tsts akroma", foil) }

    context "non-foil" do
      let(:foil) { false }
      it do
        ev[basic].should eq 0
        ev[common].should eq Rational(975, 100) * Rational(1, 121)
        ev[uncommon].should eq Rational(3, 80)
        ev[rare].should eq Rational(1, 80)
        ev[timeshifted].should eq Rational(1, 121)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(1, 4) * Rational(1, 8) * Rational(1, 20)
        ev[common].should eq Rational(1, 4) * Rational(3, 8) * Rational(1, 121)
        ev[uncommon].should eq Rational(1, 4) * Rational(2, 8) * Rational(1, 80)
        ev[rare].should eq Rational(1, 4) * Rational(1, 8) * Rational(1, 80)
        ev[timeshifted].should eq Rational(1, 4) * Rational(1, 8) * Rational(1, 121)
      end
    end
  end

  context "Planar Chaos" do
    let(:pack) { factory.for("pc") }
    let(:ev) { pack.expected_values }
    let(:common) { physical_card("e:pc Mire Boa", foil) }
    let(:uncommon) { physical_card("e:pc Necrotic Sliver", foil) }
    let(:rare) { physical_card("e:pc Akroma, Angel of Fury", foil) }
    let(:cs_common) { physical_card("e:pc Brute Force", foil) }
    let(:cs_uncommon) { physical_card("e:pc Blood Knight", foil) }
    let(:cs_rare) { physical_card("e:pc Damnation", foil) }

    context "non-foil" do
      let(:foil) { false }
      it do
        # Even in nonfoil packs (foiling assumes replaces regular common)
        # 8/40 != 3/20
        ev[common].should eq Rational(775, 100) * Rational(1, 40)
        ev[cs_common].should eq Rational(3, 1) * Rational(1, 20)
        # Same 1/20
        ev[uncommon].should eq Rational(2, 40)
        ev[cs_uncommon].should eq Rational(3, 4) * Rational(1, 15)
        # Same 1/40
        ev[rare].should eq Rational(1, 40)
        ev[cs_rare].should eq Rational(1, 4) * Rational(1, 10)
      end
    end

    # Foil rates in atypical sets are a total guess as usual
    context "foil" do
      let(:foil) { true }
      it do
        ev[common].should eq Rational(1, 4) * Rational(5, 8) * Rational(1, 40+20)
        ev[cs_common].should eq Rational(1, 4) * Rational(5, 8) * Rational(1, 40+20)
        ev[uncommon].should eq Rational(1, 4) * Rational(2, 8) * Rational(1, 40+15)
        ev[cs_uncommon].should eq Rational(1, 4) * Rational(2, 8) * Rational(1, 40+15)
        ev[rare].should eq Rational(1, 4) * Rational(1, 8) * Rational(1, 40+10)
        ev[cs_rare].should eq Rational(1, 4) * Rational(1, 8) * Rational(1, 40+10)
      end
    end
  end

  context "Vintage Masters" do
    let(:pack) { factory.for("vma") }
    let(:ev) { pack.expected_values }
    let(:common) { physical_card("e:vma r:common", foil) }
    let(:uncommon) { physical_card("e:vma r:uncommon", foil) }
    let(:rare) { physical_card("e:vma r:rare", foil) }
    let(:mythic) { physical_card("e:vma r:mythic", foil) }
    let(:special) { physical_card("e:vma r:special", foil) }

    context "non-foil" do
      let(:foil) { false }
      it do
        ev[common].should eq Rational(10, 101)
        ev[uncommon].should eq Rational(3, 80)
        ev[rare].should eq Rational(2, 240)
        ev[mythic].should eq Rational(1, 240)
        ev[special].should eq Rational(1, 480)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        # Numbers based on "non-foil power 9 twice as frequent as a mythic"
        # Actuall they say "about as", so these probably should definitely be rounded
        # in some sensible way
        #
        # Then again, it's a digital-only product, so normal print sheet constraints
        # don't affect it
        ev[common].should eq Rational(471, 480) * Rational(5, 8) * Rational(1, 101)
        ev[uncommon].should eq Rational(471, 480) * Rational(2, 8) * Rational(1, 80)
        ev[rare].should eq Rational(471, 480) * Rational(1, 8) * Rational(4, 489)
        ev[mythic].should eq Rational(471, 480) * Rational(1, 8) * Rational(2, 489)
        ev[special].should eq Rational(471, 480) * Rational(1, 8) * Rational(1, 489)
      end
    end
  end

  context "Shadows over Innistrad" do
    let(:pack) { factory.for("soi") }
    let(:ev) { pack.expected_values }
    let(:basic) { physical_card("e:soi r:basic", foil) }
    let(:dfc_common) { physical_card("e:soi r:common is:dfc", foil) }
    let(:sfc_common) { physical_card("e:soi r:common -is:dfc", foil) }
    let(:dfc_uncommon) { physical_card("e:soi r:uncommon is:dfc", foil) }
    let(:sfc_uncommon) { physical_card("e:soi r:uncommon -is:dfc", foil) }
    let(:dfc_rare) { physical_card("e:soi r:rare is:dfc", foil) }
    let(:sfc_rare) { physical_card("e:soi r:rare -is:dfc", foil) }
    let(:dfc_mythic) { physical_card("e:soi r:mythic is:dfc", foil) }
    let(:sfc_mythic) { physical_card("e:soi r:mythic -is:dfc", foil) }

    context "non-foil" do
      let(:foil) { false }
      it do
        ev[basic].should eq Rational(1, 15)
        ev[sfc_common].should eq Rational(9*32 - 8 - 4, 32) * Rational(1, 101)
        ev[sfc_uncommon].should eq Rational(3, 80)
        ev[sfc_rare].should eq Rational(2, 121)
        ev[sfc_mythic].should eq Rational(1, 121)
        ev[dfc_common].should eq Rational(3, 32)
        ev[dfc_uncommon].should eq Rational(1, 32)
        ev[dfc_rare].should eq Rational(1, 8) * Rational(2, 15)
        ev[dfc_mythic].should eq Rational(1, 8) * Rational(1, 15)
      end
    end

    context "non-foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(1, 4) * Rational(1, 8) * Rational(1,15)
        ev[sfc_common].should eq Rational(1, 4) * Rational(4, 8) * Rational(1, 105)
        ev[dfc_common].should eq Rational(1, 4) * Rational(4, 8) * Rational(1, 105)
        ev[sfc_uncommon].should eq Rational(1, 4) * Rational(2, 8) * Rational(1, 100)
        ev[dfc_uncommon].should eq Rational(1, 4) * Rational(2, 8) * Rational(1, 100)
        ev[sfc_rare].should eq Rational(1, 4) * Rational(1, 8) * Rational(2, 136)
        ev[dfc_rare].should eq Rational(1, 4) * Rational(1, 8) * Rational(2, 136)
        ev[sfc_mythic].should eq Rational(1, 4) * Rational(1, 8) * Rational(1, 136)
        ev[dfc_mythic].should eq Rational(1, 4) * Rational(1, 8) * Rational(1, 136)
      end
    end
  end

  context "Eldritch Moon" do
    let(:pack) { factory.for("emn") }
    let(:ev) { pack.expected_values }
    let(:basic) { physical_card("e:emn r:basic", foil) }
    # Meld cards can have different rarities front/back
    let(:dfc_common) { physical_card("e:emn is:front r:common (is:dfc or is:meld)", foil) }
    let(:sfc_common) { physical_card("e:emn is:front r:common -(is:dfc or is:meld)", foil) }
    let(:dfc_uncommon) { physical_card("e:emn is:front r:uncommon (is:dfc or is:meld)", foil) }
    let(:sfc_uncommon) { physical_card("e:emn is:front r:uncommon -(is:dfc or is:meld)", foil) }
    let(:dfc_rare) { physical_card("e:emn is:front r:rare (is:dfc or is:meld)", foil) }
    let(:sfc_rare) { physical_card("e:emn is:front r:rare -(is:dfc or is:meld)", foil) }
    let(:dfc_mythic) { physical_card("e:emn is:front r:mythic (is:dfc or is:meld)", foil) }
    let(:sfc_mythic) { physical_card("e:emn is:front r:mythic -(is:dfc or is:meld)", foil) }

    context "non-foil" do
      let(:foil) { false }
      it do
        ev[sfc_common].should eq Rational(10*32 - 8 - 4, 32) * Rational(1, 70)
        ev[sfc_uncommon].should eq Rational(3, 60)
        ev[sfc_rare].should eq Rational(2, 96)
        ev[sfc_mythic].should eq Rational(1, 96)
        ev[dfc_common].should eq Rational(3, 22)
        ev[dfc_uncommon].should eq Rational(1, 22)
        ev[dfc_rare].should eq Rational(1, 8) * Rational(2, 12)
        ev[dfc_mythic].should eq Rational(1, 8) * Rational(1, 12)
      end
    end

    context "non-foil" do
      let(:foil) { true }
      it do
        ev[sfc_common].should eq Rational(1, 4) * Rational(5, 8) * Rational(1, 74)
        ev[dfc_common].should eq Rational(1, 4) * Rational(5, 8) * Rational(1, 74)
        ev[sfc_uncommon].should eq Rational(1, 4) * Rational(2, 8) * Rational(1, 70)
        ev[dfc_uncommon].should eq Rational(1, 4) * Rational(2, 8) * Rational(1, 70)
        ev[sfc_rare].should eq Rational(1, 4) * Rational(1, 8) * Rational(2, 108)
        ev[dfc_rare].should eq Rational(1, 4) * Rational(1, 8) * Rational(2, 108)
        ev[sfc_mythic].should eq Rational(1, 4) * Rational(1, 8) * Rational(1, 108)
        ev[dfc_mythic].should eq Rational(1, 4) * Rational(1, 8) * Rational(1, 108)
      end
    end
  end

  context "Dominaria" do
    let(:pack) { factory.for("dom") }
    let(:ev) { pack.expected_values }
    let(:basic) { physical_card("is:booster e:dom r:basic", foil) }
    let(:common) { physical_card("is:booster e:dom r:common", foil) }
    let(:legendary_uncommon) { physical_card("is:booster e:dom r:uncommon t:legendary", foil) }
    let(:nonlegendary_uncommon) { physical_card("is:booster e:dom r:uncommon -t:legendary", foil) }
    let(:legendary_rare) { physical_card("is:booster e:dom r:rare t:legendary", foil) }
    let(:nonlegendary_rare) { physical_card("is:booster e:dom r:rare -t:legendary", foil) }
    let(:legendary_mythic) { physical_card("is:booster e:dom r:mythic t:legendary", foil) }
    let(:nonlegendary_mythic) { physical_card("is:booster e:dom r:mythic -t:legendary", foil) }

    context "non-foil" do
      let(:foil) { false }
      it do
        ev[basic].should eq Rational(1, 20)
        ev[common].should eq Rational(975, 100) * Rational(1, 101)
        ev[legendary_uncommon].should eq Rational(3, 80)
        ev[legendary_rare].should eq Rational(2, 121)
        ev[legendary_mythic].should eq Rational(1, 121)
        ev[nonlegendary_uncommon].should eq Rational(3, 80)
        ev[nonlegendary_rare].should eq Rational(2, 121)
        ev[nonlegendary_mythic].should eq Rational(1, 121)
      end
    end

    context "non-foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(1,4) * Rational(1, 20) * Rational(4,32)
        ev[common].should eq Rational(1,4) * Rational(1, 101) * Rational(16,32)
        ev[legendary_uncommon].should eq Rational(1,4) * Rational(1, 80) * Rational(8,32)
        ev[legendary_rare].should eq Rational(1,4) * Rational(2, 121) * Rational(4,32)
        ev[legendary_mythic].should eq Rational(1,4) * Rational(1, 121) * Rational(4,32)
        ev[nonlegendary_uncommon].should eq Rational(1,4) * Rational(1, 80) * Rational(8,32)
        ev[nonlegendary_rare].should eq Rational(1,4) * Rational(2, 121) * Rational(4,32)
        ev[nonlegendary_mythic].should eq Rational(1,4) * Rational(1, 121) * Rational(4,32)
      end
    end
  end

  context "M19" do
    let(:pack) { factory.for("m19") }
    let(:ev) { pack.expected_values }
    let(:basic) { physical_card("is:booster e:m19 r:basic", foil) }
    let(:common) { physical_card("is:booster e:m19 r:common", foil) }
    let(:uncommon) { physical_card("is:booster e:m19 r:uncommon", foil) }
    let(:rare) { physical_card("is:booster e:m19 r:rare", foil) }
    let(:mythic) { physical_card("is:booster e:m19 r:mythic -is:dfc", foil) }
    let(:bolas) { physical_card("e:m19 (Nicol Bolas, the Ravager)", foil) }

    context "non-foil" do
      let(:foil) { false }
      it do
        ev[basic].should eq Rational(1, 20)
        ev[common].should eq Rational(975, 100) * Rational(1, 111)
        ev[uncommon].should eq Rational(3, 80)
        ev[rare].should eq Rational(2, 122)
        ev[mythic].should eq Rational(1, 122)
        ev[bolas].should eq Rational(1, 122)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(1,4) * Rational(1, 20) * Rational(4,32)
        ev[common].should eq Rational(1,4) * Rational(1, 111) * Rational(16,32)
        ev[uncommon].should eq Rational(1,4) * Rational(1, 80) * Rational(8,32)
        ev[rare].should eq Rational(1,4) * Rational(2, 122) * Rational(4,32)
        ev[mythic].should eq Rational(1,4) * Rational(1, 122) * Rational(4,32)
        ev[bolas].should eq Rational(1,4) * Rational(1, 122) * Rational(4,32)
      end
    end
  end

  # Foil rates are total speculation
  # But there's definitely separate draft and nondraft foils
  context "Conspiracy" do
    let(:pack) { factory.for("cns") }
    let(:ev) { pack.expected_values }
    let(:common) { physical_card("e:cns -is:draft r:common", foil) }
    let(:uncommon) { physical_card("e:cns -is:draft r:uncommon", foil) }
    let(:rare) { physical_card("e:cns -is:draft r:rare", foil) }
    let(:mythic) { physical_card("e:cns -is:draft r:mythic", foil) }
    let(:draft_common) { physical_card("e:cns is:draft r:common", foil) }
    let(:draft_uncommon) { physical_card("e:cns is:draft r:uncommon", foil) }
    let(:draft_rare) { physical_card("e:cns is:draft r:rare", foil) }

    context "non-foil" do
      let(:foil) { false }
      it do
        ev[common].should eq Rational(975, 100) * Rational(1, 80)
        ev[uncommon].should eq Rational(3, 60)
        ev[rare].should eq Rational(2, 80)
        ev[mythic].should eq Rational(1, 80)
        ev[draft_common].should eq Rational(39, 40) * Rational(8, 120)
        ev[draft_uncommon].should eq Rational(39, 40) * Rational(4, 120)
        ev[draft_rare].should eq Rational(39, 40) * Rational(2, 120)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[common].should eq Rational(1, 4) * Rational(1, 80) * Rational(5, 8)
        ev[uncommon].should eq Rational(1, 4) * Rational(1, 60) * Rational(2, 8)
        ev[rare].should eq Rational(1, 4) * Rational(2, 80) * Rational(1, 8)
        ev[mythic].should eq Rational(1, 4) * Rational(1, 80) * Rational(1, 8)
        ev[draft_common].should eq Rational(1, 40) * Rational(8, 120)
        ev[draft_uncommon].should eq Rational(1, 40) * Rational(4, 120)
        ev[draft_rare].should eq Rational(1, 40) * Rational(2, 120)
      end
    end
  end

  context "sets with explicit print sheets" do
    let(:pack) { factory.for(set_code) }
    let(:ev) { pack.expected_values }
    let(:cards) { db.search("++ e:#{set_code}").printings }
    let(:expected_ev) do
      cards.map do |card|
        sheet = card.print_sheet[0]
        count = card.print_sheet[1..-1].to_i
        [
          PhysicalCard.for(card),
          Rational(count * booster_contents[sheet], sheet_size[sheet])
        ]
      end.to_h
    end

    context "Alliances" do
      let(:set_code) { "ai" }
      let(:booster_contents) { {"C"=>8, "U"=>3, "R"=>1} }
      let(:sheet_size) { {"C"=>110, "U"=>110, "R"=>110} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Antiquities" do
      let(:set_code) { "aq" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Arabian Nights" do
      let(:set_code) { "an" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Chronicles" do
      let(:set_code) { "ch" }
      let(:booster_contents) { {"C"=>9, "U"=>3} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Fallen Empires" do
      let(:set_code) { "fe" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Homelands" do
      let(:set_code) { "hl" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Legends" do
      let(:set_code) { "lg" }
      let(:booster_contents) { {"C"=>12, "U"=>3, "R"=>1} }
      let(:sheet_size) { {"C"=>121, "U"=>121, "R"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "The Dark" do
      let(:set_code) { "dk" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end
  end
end
