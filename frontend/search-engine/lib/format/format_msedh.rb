# This is loaded manually in format.rb, go there to tell it to load more formats or change the order.

class FormatMSEDH < Format
  def format_pretty_name
    "MSEDH"
  end

    def build_included_sets
    Set[
      "afm", "kzd", "awk",
      "toj", "imp", "psa",
      "pfp", "twr", 
      "gnj", "sur",
      "oph", "orp",
      "cac",
      "dya",
      "hi12",
      "k15",
      "klc",
      "lng",
      "mis",
      "nva",
      "poa",
      "sor",
      "tge",
      "tow",
      "xpm",
      "zer",
      "l",
    ]
    end

end
