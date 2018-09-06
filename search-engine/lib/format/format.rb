class Format
  attr_reader :included_sets, :excluded_sets

  def initialize(time=nil)
    raise ArgumentError unless time.nil? or time.is_a?(Date)
    @time = time
    @ban_list = BanList[format_name]
    if respond_to?(:build_included_sets)
      @included_sets = build_included_sets
      @excluded_sets = nil
    else
      @included_sets = nil
      @excluded_sets = build_excluded_sets
    end
  end

  def legality(card)
    if card.extra or !in_format?(card)
      nil
    else
      @ban_list.legality(card.name, @time)
    end
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      if @included_sets
        next unless @included_sets.include?(printing.set_code)
      else
        next if @excluded_sets.include?(printing.set_code)
      end
      return true
    end
    false
  end

  def format_pretty_name
    raise "Subclass responsibility"
  end

  def format_name
    format_pretty_name.downcase
  end

  def to_s
    if @time
      "<Format:#{format_name}:#{@time}>"
    else
      "<Format:#{format_name}>"
    end
  end

  def inspect
    to_s
  end

  def ban_events
    @ban_list.events
  end

  class << self
    def formats_index
      # Removed spaces so you can say "lw block" lw-block lwblock lw_block or whatever
      {
        "msem2"                      => FormatMSEM2,
        "msedh"                      => FormatMSEDH
      }
    end

    def all_format_classes
      formats_index.values.uniq
    end

    def [](format_name)
      format_name = format_name.downcase.gsub(/\s|-|_/, "")
      formats_index[format_name] || FormatUnknown
    end
  end
end

Dir["#{__dir__}/format_*.rb"].each do |path| require_relative path end

# formats = Dir["#{__dir__}/format_*.rb"]
# puts("Loading formats: #{formats}")

