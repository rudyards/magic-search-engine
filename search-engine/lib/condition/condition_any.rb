class ConditionAny < ConditionSimple
  def initialize(query)
    @query = query.downcase
    @subqueries = [
      ConditionWord.new(query)
    ]
    @query_hard_normalized = hard_normalize(@query)
  end

  # This is going to be pretty slow
  def match?(card)
    return true if @subqueries.any?{|sq| sq.match?(card)}
    foreign_names = (card.foreign_names || {}).values.flatten
    return true if foreign_names.any?{|n|
      hard_normalize(n).include?(@query_hard_normalized)
    }
    false
  end

  def to_s
    "any:#{maybe_quote(@query)}"
  end

  private

  def hard_normalize(s)
    UnicodeUtils.downcase(UnicodeUtils.nfd(s).gsub(/\p{Mn}/, ""))
  end
end