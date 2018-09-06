describe "is:booster" do
  include_context "db"

  it "set has boosters" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      should_have_boosters = (
        ["expansion", "core", "un", "reprint", "conspiracy", "masters", "starter", "two-headed giant"].include?(set.type) and
        !%W[ced cedi tsts itp st2k cp1 cp2 cp3 w16 w17].include?(set.code)
      )
      if should_have_boosters
        set.should have_boosters, "#{set_pp} should have boosters"
      else
        set.should_not have_boosters, "#{set_pp} should not have boosters"
      end
    end
  end

  it "card is in boosters" do
    db.sets.each do |set_code, set|
      # Exclude planesawlker deck cards
      case set_code
      when "kld"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=264"
      when "aer"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=184"
      when "akh"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=269"
      when "hou"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=199"
      when "xln"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=279"
      when "rix"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=196"
      when "dom"
        # This also excludes Firesong and Sunspeaker buy-a-box promo
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=269"
      when "ori"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=272"
      when "m19"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=280"
      when "ogw"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} (-t:basic or number:/A/)"
      when "bfz"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} (-t:basic or number:/A/)"
      else
        if set.has_boosters?
          assert_search_equal "e:#{set_code} is:booster", "e:#{set_code}"
        else
          assert_search_equal "e:#{set_code} -is:booster", "e:#{set_code}"
        end
      end
    end
  end
end
