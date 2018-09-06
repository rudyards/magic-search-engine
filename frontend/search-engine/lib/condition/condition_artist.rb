class ConditionArtist < ConditionSimple
  def initialize(artist)
    @artist = artist.downcase
  end

  def match?(card)
    card.artist_name.downcase.include?(@artist)
  end

  def to_s
    "a:#{maybe_quote(@artist)}"
  end
end
