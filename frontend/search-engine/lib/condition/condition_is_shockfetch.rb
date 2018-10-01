class ConditionIsShockfetch < Condition
  def search(db)
    names = [
      "ocean monastery",
      "flooded depths",
      "shardstone rift",
      "amber hills",
      "barren desolation",
      "timber range",
      "grim bastion",
      "magmatic torrent",
      "sunlit highland",
      "mysterious cataract",
    ]

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:shockfetch"
  end
end
