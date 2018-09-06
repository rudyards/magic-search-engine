# This is just a start of what any: is supposed to do
describe "Any queries" do
  include_context "db"

  context "card name" do
    it do
      assert_search_results %Q[any:"Abrupt Decay"], "Abrupt Decay"
    end
    it "is case insensitive" do
      assert_search_equal %Q[any:"ABRUPT decay"], %Q[any:"Abrupt Decay"]
    end
  end

  it "includes German name" do
    assert_search_equal %Q[any:"Abrupter Verfall"], %Q[de:"Abrupter Verfall"]
  end

  context "French name" do
    it do
      assert_search_equal %Q[any:"Décomposition abrupte"], %Q[fr:"Décomposition abrupte"]
    end
    it "is case insensitive" do
      assert_search_equal %Q[any:"Décomposition abrupte"], %Q[any:"décomposition ABRUPTE"]
    end
    it "ignores diacritics" do
      assert_search_equal %Q[any:"Décomposition abrupte"], %Q[any:"Decomposition abrupte"]
    end
  end

  it "includes Italian name" do
    assert_search_equal %Q[any:"Deterioramento Improvviso"], %Q[it:"Deterioramento Improvviso"]
  end

  it "includes Japanese name" do
    assert_search_equal %Q[any:"血染めの月"], %Q[jp:"血染めの月"]
  end

  it "includes Russian name" do
    assert_search_equal %Q[any:"Кровавая луна"], %Q[ru:"Кровавая луна"]
  end

  it "includes Spanish name" do
    assert_search_equal %Q[any:"Puente engañoso"], %Q[sp:"Puente engañoso"]
  end

  it "includes Portuguese name" do
    assert_search_equal %Q[any:"Ponte Traiçoeira"], %Q[pt:"Ponte Traiçoeira"]
  end

  it "includes Korean name" do
    assert_search_equal %Q[any:"축복받은 신령들"], %Q[kr:"축복받은 신령들"]
  end

  it "includes Chinese Traditional name" do
    assert_search_equal %Q[any:"刻拉諾斯的電擊"], %Q[ct:"刻拉諾斯的電擊"]
  end

  it "includes Chinese Simplified name" do
    assert_search_equal %Q[any:"刻拉诺斯的电击"], %Q[cs:"刻拉诺斯的电击"]
  end

  context "artist" do
    it do
      assert_search_equal %Q[any:"Wayne England"], %Q[a:"Wayne England"]
    end
    it "is case insensitive" do
      assert_search_equal %Q[any:"Wayne England"], %Q[any:"WAYNE england"]
    end
  end

  context "flavor text" do
    it do
      assert_search_equal %Q[any:"Jaya Ballard"], %Q[ft:"Jaya Ballard" OR ("Jaya Ballard")]
    end
    it "is case insensitive" do
      assert_search_equal %Q[any:"Jaya Ballard"], %Q[any:"JAYA ballard"]
    end
  end

  context "Oracle text" do
    it do
      assert_search_equal %Q[any:"win the game"], %Q[o:"win the game"]
    end
    it "is case insensitive" do
      assert_search_equal %Q[any:"win the game"], %Q[any:"Win THE gaME"]
    end
  end

  context "Typeline" do
    it do
      assert_search_equal %Q[any:"legendary goblin"], %Q[t:"legendary goblin"]
    end
    it "is case insensitive" do
      assert_search_equal %Q[any:"legendary goblin"], %Q[any:"Legendary GOBLIN"]
    end
  end

  context "rarity" do
    # These words conflict a good deal
    # Rare-B-Gone Oracle text mentions "mythic rare"
    it do
      assert_search_equal %Q[any:"mythic"], %Q[r:"mythic" or ft:"mythic" or o:"mythic" or "Mythic Proportions"]
    end
    it "aliases" do
      assert_search_equal %Q[any:"mythic rare"], %Q[r:"mythic" or o:"mythic rare"]
    end
    it "is case insensitive" do
      assert_search_equal %Q[any:"UNCOMMON"], %Q[any:"uncommon"]
    end
  end

  context "color" do
    # A lot of mentions, so let's just get one set and test it there
    it "white" do
      assert_search_equal "e:rtr any:white", "e:rtr (c>=w or o:white)"
    end
    it "blue" do
      assert_search_equal "e:rtr any:blue", "e:rtr (c>=u or o:blue)"
    end
    it "black" do
      assert_search_equal "e:rtr any:black", "e:rtr (c>=b or o:black)"
    end
    it "red" do
      assert_search_equal "e:rtr any:red", "e:rtr (red or c>=r or o:red or foreign:red)"
    end
    it "green" do
      assert_search_equal "e:rtr any:green", "e:rtr (c>=g or o:green)"
    end
    it "colorless" do
      assert_search_equal "e:rtr any:colorless", "e:rtr (c=c or o:colorless)"
    end
  end

  # TODO: maybe do weird ones like Tarmogoyf's */1+* too
  context "p/t" do
    it do
      assert_search_equal %Q[any:"2/4" any:spider], "pow=2 tou=4 t:spider"
      assert_search_equal %Q[any:"-1/3"], "pow=-1 tou=3"
      # This is very problematic as -1/-1 is very common in Oracle text
      assert_search_equal %Q[any:"-1/-1"], %Q[(pow=-1 tou=-1) or o:"-1/-1"]
    end
  end

  context "is:" do
    it "augment" do
      assert_search_equal "any:augment", "is:augment or o:augment or ft:augment or (augment) or foreign:augment"
    end

    it "battleland" do
      assert_search_equal "any:battleland", "is:battleland"
    end

    it "bounceland" do
      assert_search_equal "any:bounceland", "is:bounceland"
    end

    it "checkland" do
      assert_search_equal "any:checkland", "is:checkland"
    end

    it "commander" do
      assert_search_equal "any:commander", "is:commander or ft:commander or o:commander or (commander) or foreign:commander"
    end

    it "digital" do
      assert_search_equal "any:digital", "is:digital or foreign:digital"
    end

    it "dual" do
      assert_search_equal "any:dual", "is:dual or (dual) or ft:dual"
    end

    it "fastland" do
      assert_search_equal "any:fastland", "is:fastland"
    end

    it "fetchland" do
      assert_search_equal "any:fetchland", "is:fetchland"
    end

    it "filterland" do
      assert_search_equal "any:filterland", "is:filterland"
    end

    it "funny" do
      assert_search_equal "any:funny", "is:funny or ft:funny"
    end

    it "gainland" do
      assert_search_equal "any:gainland", "is:gainland"
    end

    it "manland" do
      assert_search_equal "any:manland", "is:manland"
    end

    it "multipart" do
      assert_search_equal "any:multipart", "is:multipart"
    end

    it "permanent" do
      assert_search_equal "any:permanent", "is:permanent or o:permanent or ft:permanent"
    end

    it "primary" do
      assert_search_equal "any:primary", "is:primary"
    end

    it "secondary" do
      assert_search_equal "any:secondary", "is:secondary"
    end

    it "front" do
      assert_search_equal "any:front", "is:front or ft:front"
    end

    it "back" do
      assert_search_equal "any:back", "is:back or o:back or ft:back or (back)"
    end

    it "booster" do
      assert_search_equal "any:booster", "is:booster or o:booster"
    end

    it "promo" do
      assert_search_equal "any:promo", "is:promo or foreign:promo"
    end

    it "reprint" do
      assert_search_equal "any:reprint", "is:reprint"
    end

    it "reserved" do
      assert_search_equal "any:reserved", "is:reserved or ft:reserved"
    end

    it "scryland" do
      assert_search_equal "any:scryland", "is:scryland"
    end

    it "shockland" do
      assert_search_equal "any:shockland", "is:shockland"
    end

    it "spell" do
      assert_search_equal "any:spell", "is:spell or o:spell"
    end

    it "timeshifted" do
      assert_search_equal "any:timeshifted", "is:timeshifted"
    end

    it "unique" do
      assert_search_equal "any:unique", "is:unique or ft:unique"
    end

    it "vanilla" do
      assert_search_equal "any:vanilla", "is:vanilla"
    end

    it "draft" do
      # 4 cards with draft in name
      assert_search_equal "any:draft", "is:draft or draft"
    end
  end
end
