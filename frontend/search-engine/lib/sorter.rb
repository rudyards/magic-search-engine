class Sorter
  COLOR_ORDER = ["w", "u", "b", "r", "g", "uw", "bu", "br", "gr", "gw", "bw", "ru", "bg", "rw", "gu", "buw", "bru", "bgr", "grw", "guw", "brw", "gru", "bgw", "ruw", "bgu", "bruw", "bgru", "bgrw", "gruw", "bguw", "bgruw", ""].each_with_index.to_h.freeze

  # Fallback sorting for printings of each card:
  # * not MTGO only
  # * new frame
  # * Standard only printing
  # * most recent
  # * set name
  # * card number as integer (10 > 2)
  # * card number as string (10A > 10)

  attr_reader :warnings, :sort_order

  def initialize(sort_order, seed)
    known_sort_orders = ["ci", "cmc", "color", "name", "new", "newall", "number", "old", "oldall", "pow", "rand", "rarity", "tou"]
    known_sort_orders += known_sort_orders.map{|s| "-#{s}"}

    @seed = seed
    @sort_order = sort_order ? sort_order.split(",") : []
    @warnings = []
    @sort_order = @sort_order.map do |part|
      if known_sort_orders.include?(part)
        part
      else
        @warnings << "Unknown sort order: #{part}"
        nil
      end
    end.compact
    @sort_order = nil if @sort_order.empty?
  end

  def sort(results)
    return results.sort_by(&:default_sort_index) unless @sort_order
    results.sort_by do |c|
      card_key(c)
    end
  end

  def ==(other)
    other.is_a?(Sorter) and sort_order == other.sort_order and warnings == other.warnings
  end

  private

  def card_key(c)
    @sort_order.flat_map do |part|
      case part
      when "new", "-old"
        [c.set.regular? ? 0 : 1, -c.release_date_i]
      when "old", "-new"
        [c.set.regular? ? 0 : 1, c.release_date_i]
      when "newall", "-oldall"
        [-c.release_date_i]
      when "oldall", "-newall"
        [c.release_date_i]
      when "cmc"
        [c.cmc ? 0 : 1, -c.cmc.to_i]
      when "-cmc"
        [c.cmc ? 0 : 1, c.cmc.to_i]
      when "pow"
        [c.power ? 0 : 1, -c.power.to_i]
      when "-pow"
        [c.power ? 0 : 1, c.power.to_i]
      when "tou"
        [c.toughness ? 0 : 1, -c.toughness.to_i]
      when "-tou"
        [c.toughness ? 0 : 1, c.toughness.to_i]
      when "rand", "-rand"
        [Digest::MD5.hexdigest(@seed + c.name)]
      when "number"
        [c.set.name, c.number.to_i, c.number]
      when "-number"
        [c.set.name, -c.number.to_i, reverse_string_order(c.number)]
      when "color"
        [COLOR_ORDER.fetch(c.colors)]
      when "-color"
        [-COLOR_ORDER.fetch(c.colors)]
      when "ci"
        [COLOR_ORDER.fetch(c.color_identity)]
      when "-ci"
        [-COLOR_ORDER.fetch(c.color_identity)]
      when "rarity"
        [-c.rarity_code]
      when "-rarity"
        [c.rarity_code]
      when "name"
        [c.name]
      when "-name"
        [reverse_string_order(c.name)]
      else # unknown key, should have been caught by initializer
        raise "Invalid sort order #{part}"
      end
    end + [c.default_sort_index]
  end

  # This is a stupid hack, and also really slow
  def reverse_string_order(s)
    s.unpack("U*").map{|code| -code}
  end
end
