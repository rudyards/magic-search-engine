class FormatMSEM2 < Format
  def format_pretty_name
    "MSEM2"
  end

  def build_included_sets
    Set[
      "afm", "kzd", "awk",
      "toj", "imp", #"psa",
      "pfp", "twr", 
      "gnj", "sur",
      "oph", #"orp",
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
