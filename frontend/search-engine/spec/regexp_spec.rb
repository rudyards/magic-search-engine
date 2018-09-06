describe "Regexp" do
  include_context "db"

  context "handles parse errors" do
    it "o:" do
      Query.new('o:/\d+/').warnings.should eq([])
      Query.new('o:/[a-z/').warnings.should eq(["bad regular expression in o:/[a-z/ - premature end of char-class: /[a-z/i"])
      Query.new('o:/[a-z]/').warnings.should eq([])
    end

    it "ft:" do
      Query.new('FT:/[a-z/').warnings.should eq(["bad regular expression in FT:/[a-z/ - premature end of char-class: /[a-z/i"])
      Query.new('FT:/[a-z]/').warnings.should eq([])
    end

    it "a:" do
      Query.new('a:/[a-z/').warnings.should eq(["bad regular expression in a:/[a-z/ - premature end of char-class: /[a-z/i"])
      Query.new('a:/[a-z]/').warnings.should eq([])
    end

    it "n:" do
      Query.new('n:/[a-z/').warnings.should eq(["bad regular expression in n:/[a-z/ - premature end of char-class: /[a-z/i"])
      Query.new('n:/[a-z]/').warnings.should eq([])
    end
  end

  it "handles timeouts" do
    # It's quite hard to construct pathological regexp by accident
    proc{ search('o:/([^e]?){50}[^e]{50}/') }.should raise_error(Timeout::Error)
  end

  it "regexp oracle text" do
    assert_search_results 'o:/\d{3,}/',
      "1996 World Champion",
      "Ajani, Mentor of Heroes",
      "As Luck Would Have It",
      "Battle of Wits",
      "Helix Pinnacle",
      "Mox Lotus",
      "Rules Lawyer",
      "Urza, Academy Headmaster"
  end

  it "regexp flavor text" do
    assert_search_results 'ft:/\d{4,}/',
      "Akroma, Angel of Wrath Avatar",
      "Fallen Angel Avatar",
      "Goblin Secret Agent",
      "Gore Vassal",
      "Invoke the Divine",
      "Mise",
      "Nalathni Dragon",
      "Remodel"

    assert_search_equal 'ft:/ajani/', 'FT:/ajani/'
    assert_search_equal 'ft:/ajani/', 'FT:/AJANI/'
    assert_search_equal 'ft:/land/', 'FT:/(?i)land/'
    assert_search_differ 'ft:/land/', 'FT:/(?-i)land/'
    assert_search_differ 'ft:/land/', 'FT:/\bland\b/'
  end

  it "regexp artist text" do
    db.search("a:/.{40}/").printings.map(&:artist_name).should eq([
      "Jim \"Stop the Da Vinci Beatdown\" Pavelec",
      "Edward P. Beard, Jr. & Anthony S. Waters",
      "Pete \"Yes the Urza's Legacy One\" Venters",
      "Alan \"Don't Feel Like You Have to Pick Me\" Pollack",
      "Edward P. Beard, Jr. & Anthony S. Waters",
    ])
  end

  it "regexp name text" do
    assert_search_results "f:modern n:/.{30}/",
      "Circle of Protection: Artifacts",
      "Coax from the Blind Eternities",
      "Hanweir, the Writhing Township",
      "Ib Halfheart, Goblin Tactician",
      "Minamo, School at Water's Edge",
      "Okina, Temple to the Grandfathers",
      "Oviya Pashiri, Sage Lifecrafter",
      "Sunhome, Fortress of the Legion"
  end
end
