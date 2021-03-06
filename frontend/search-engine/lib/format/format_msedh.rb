# This is loaded manually in format.rb, go there to tell it to load more formats or change the order.

class FormatMSEDH < Format
  def format_pretty_name
    "MSEDH"
  end

    def build_included_sets
    Set[
      "AFM", "KZD",
      "TOJ", "IMP", "PSA",
      "PFP", "TWR", 
      "GNJ", "SUR",
      "OPH", "ORP",
      "CAC",
      "DYA",
      "HI12",
      "K15",
      "KLC",
      "LNG",
      "MIS",
      "NVA",
      "POA",
      "SOR",
      "TGE",
      "TOW",
      "XPM",
      "ZER",
      "L",
    ]
    end

end
