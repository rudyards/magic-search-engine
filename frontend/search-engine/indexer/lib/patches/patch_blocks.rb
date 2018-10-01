class PatchBlocks < Patch
  MagicBlocks = [
    ["KZD", nil, "Khaliz-Dorahn", "KZD", "AFM"],
    ["IMP", nil, "Imperial Legacies", "IMP", "PSA", "TOJ"],
    ["TWR", nil, "A Tourney at Whiterun", "TWR", "PFP"],
    ["GNJ", nil, "Goliaths of Nangjiao", "GNJ", "SUR"],
    ["OPH", nil, "Ophorio", "OPH", "ORP",],
    ["CAC", nil, "Carpe Arcanum", "CAC"],
    ["DYA", nil, "Death of Yakizma", "DYA"],
    ["HI12", nil, "High Noon", "HI12"],
    ["K15", nil, "Kore Set 2015", "K15"],
    ["KLC", nil, "Kaleidoscope", "KLC"],
    ["LNG", nil, "Langor", "LNG"],
    ["MIS", nil, "Mious", "MIS"],
    ["NVA", nil, "Novea", "NVA"],
    ["POA", nil, "Pyramids of Atuum", "POA"],
    ["SOR", nil, "Spark of Revolution", "SOR"],
    ["TGE", nil, "The Golden Era", "TGE"],
    ["TOW", nil, "Tides of War", "TOW"],
    ["XPM", nil, "Xoltan Pre Modern", "XPM"],
    ["ZER", nil, "Zero", "ZER"],
    ["L", nil, "The Land Bundle", "L"],

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
