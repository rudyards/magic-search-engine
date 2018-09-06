class PatchBlocks < Patch
  MagicBlocks = [
    ["kzd", nil, "Khaliz-Dorahn", "kzd", "afm"],
    ["imp", nil, "Imperial Legacies", "imp", "psa", "toj"],
    ["twr", nil, "A Tourney at Whiterun", "twr", "pfp"],
    ["gnj", nil, "Goliaths of Nangjiao", "gnj", "sur"],
    ["oph", nil, "Ophorio", "oph", "orp",],
    ["cac", nil, "Carpe Arcanum", "cac"],
    ["dya", nil, "Death of Yakizma", "dya"],
    ["hi12", nil, "High Noon", "hi12"],
    ["k15", nil, "Kore Set 2015", "k15"],
    ["klc", nil, "Kaleidoscope", "klc"],
    ["lng", nil, "Langor", "lng"],
    ["mis", nil, "Mious", "mis"],
    ["nva", nil, "Novea", "nva"],
    ["poa", nil, "Pyramids of Atuum", "poa"],
    ["sor", nil, "Spark of Revolution", "sor"],
    ["tge", nil, "The Golden Era", "tge"],
    ["tow", nil, "Tides of War", "tow"],
    ["xpm", nil, "Xoltan Pre Modern", "xpm"],
    ["zer", nil, "Zero", "zer"],
    ["l", nil, "The Land Bundle", "l"],

  ]

  def block_by_set_code(set_code)
    MagicBlocks.find do |block_info|
      block_info[3..-1].include?(set_code)
    end
  end

  def call
    each_set do |set|
      code, code2, name = block_by_set_code(set["code"])
      set.merge!({
        "block_code" => code,
        "official_block_code" => code2,
        "block_name" => name,
      }.compact)
    end
  end
end
