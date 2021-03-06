
Gem::Specification.new do |s|
  s.name             = "commission_junction"
  s.version          = "1.1"
  s.date             = "2008-09-23"
  s.summary          = "Commission Junction SOAP API" 
  s.email            = "farleyknight@gmail.com"
  s.homepage         = "http://github.com/farleyknight/commission_junction/"
  s.description      = "Commission Junction SOAP API"
  s.has_rdoc         = true
  s.authors          = ["Farley Knight"]
  s.files            = [
    "History.txt", "Manifest.txt", "README.txt", "Rakefile", 
    "commission_junction.gemspec", 
    "lib/commission_junction.rb", 
    "lib/commission_junction/migrate.rb", 
    "lib/commission_junction/search_link.rb", 
    "lib/commission_junction/ext.rb", 
    "examples/based_on_website.rb"]
  s.rdoc_options     = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
end


