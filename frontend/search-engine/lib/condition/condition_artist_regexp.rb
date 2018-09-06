class ConditionArtistRegexp < ConditionRegexp
  def match?(card)
    card.artist_name =~ @regexp
  end

  def to_s
    "a:#{@regexp.inspect.sub(/i\z/, "")}"
  end
end
