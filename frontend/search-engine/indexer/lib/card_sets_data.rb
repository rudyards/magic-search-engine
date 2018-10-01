class CardSetsData
  def initialize
    @data = set_paths.map{|path| load_path(path)}.sort_by{|set_code, set|
      [set["releaseDate"] || "9999-12-31", set_code]
    }.to_h
  end

  def sets_path
    Indexer::ROOT + "sets"
  end

  def set_paths
    @set_paths ||= sets_path.glob("*.json")
  end

  def load_path(path)
    [path.basename(".json").to_s, JSON.parse(path.read)]
  end

  def each_set(&block)
    @data.each(&block)
  end
end
