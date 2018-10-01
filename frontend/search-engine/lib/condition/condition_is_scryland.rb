class ConditionIsScryland < Condition
  def search(db)
    names = [
      "winterheath pass",
      "chillroad pass",
      "stonework gate pass",
      "hanatun pass",
      "sunset grove pass",
      "ravenwood pass",
      "sky’s reach pass",
      "grimrot pass",
      "glory bridge pass",
      "frozen wilds pass",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:scryland"
  end
end
