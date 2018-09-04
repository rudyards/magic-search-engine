require "pathname"
require "fileutils"

def db
  @db ||= begin
    require_relative "search-engine/lib/card_database"
    CardDatabase.load
  end
end

task "default" => "spec"
task "test" => "spec"

# Run specs
task "spec" do
  Dir.chdir("search-engine") do
    sh "rspec"
  end
  Dir.chdir("frontend") do
    sh "rake test"
  end
end

desc "Generate index"
task "index" do
  sh "./indexer/bin/indexer"
end


desc "Fetch MSEM pics"
task "pics:MSEM" do
  pics = Pathname("frontend/public/cards")
  db.printings.each do |c|
    next unless c.multiverseid
    path = pics + Pathname("#{c.set_code}/#{c.number}.jpg")
    path.parent.mkpath
    next if path.exist?
    url = "http://mse-modern.com/MSEM2/Images/"
    puts "Downloading #{c.name} #{c.set_code} #{c.multiverseid}"
    system "wget", "-nv", "-nc", url, "-O", path.to_s
  end
end

desc "Connect links to HQ pics"
task "link:pics" do
  Pathname("frontend/public/cards_hq").mkpath
  if ENV["RAILS_ENV"] == "production"
    sources = Dir["/home/rails/magic-card-pics-hq-*/*/"]
  else
    sources = Dir["#{ENV['HOME']}/github/magic-card-pics-hq-*/*/"]
  end
  sources.each do |source|
    source = Pathname(source)
    set_name = source.basename.to_s
    target_path = Pathname("frontend/public/cards_hq/#{set_name}")
    next if target_path.exist?
    # p [target_path, source]
    target_path.make_symlink(source)
  end
end

desc "Fetch HQ pics"
task "pics:hq" do
  sh "./bin/fetch_hq_pics"
end

desc "Print basic statistics about card pictures"
task "pics:statistics" do
  sh "./bin/pics_statistics"
end

desc "Clanup Rails files"
task "clean" do
  [
    "frontend/Gemfile.lock",
    "frontend/log/development.log",
    "frontend/log/production.log",
    "frontend/log/test.log",
    "frontend/tmp",
    "search-engine/.respec_failures",
    "search-engine/coverage",
    "search-engine/Gemfile.lock",
  ].each do |path|
    system "trash", path if Pathname(path).exist?
  end
  Dir["**/.DS_Store"].each do |ds_store|
    FileUtils.rm ds_store
  end
end

desc "Fetch new Comprehensive Rules"
task "rules:update" do
  sh "bin/fetch_comp_rules"
  sh "bin/format_comp_rules"
end
