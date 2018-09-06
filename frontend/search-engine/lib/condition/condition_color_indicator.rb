class ConditionColorIndicator < ConditionSimple
  def initialize(indicator)
    @indicator = indicator.downcase.gsub(/ml/, "").chars.to_set
    @indicator_name = color_indicator_name(@indicator)
  end

  # Only exact match
  # There's no way to say "has no color indicator"
  def match?(card)
    card.color_indicator and @indicator_name == card.color_indicator
  end

  def to_s
    "in:#{@indicator.to_a.join}"
  end

private

  # This must match Card.color_indicator_name
  # (but won't be identical to it)
  def color_indicator_name(indicator)
    names = {"w" => "white", "u" => "blue", "b" => "black", "r" => "red", "g" => "green"}
    color_indicator = names.map{|c,cv| indicator.include?(c) ? cv : nil}.compact
    case color_indicator.size
    when 5
      "all colors"
    when 1, 2
      color_indicator.join(" and ")
    when 0
      # devoid and Ghostfire - for some reason they use rules text, not color indicator
      # "colorless"
      nil # You can ask, but no matches possible
    else # find phrasing for 3/4 colors
      nil # You can ask, but no matches possible
    end
  end
end
