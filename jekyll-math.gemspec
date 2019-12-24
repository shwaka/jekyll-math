Gem::Specification.new do |s|
  s.name = 'jekyll-math'
  s.version = '0.1.0'
  s.summary = "Crossreferencing and math typesetting"
  s.description = "Crossreferencing and math typesetting"
  s.authors = ["Shun Wakatsuki"]
  s.email = 'shun.wakatsuki@gmail.com'
  s.files = ["lib/jekyll-math.rb"]
  s.homepage = 'https://github.com/shwaka/jekyll-math'
  s.license = 'MIT'
  s.add_dependency "nokogiri"
  s.add_dependency "zotica"
  s.add_dependency "jekyll"
end
