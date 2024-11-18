Gem::Specification.new do |s|
  s.name        = 'curses-extension'
  s.version     = '3.0.2'
  s.licenses    = ['Unlicense']
  s.summary     = "Extending the Ruby Curses module with some obvious functionality"
  s.description = 'The Ruby curses library is sorely lacking some important features. This class extension adds a set of features that makes it much easier to create and manage terminal curses applications in Ruby. See the Github page for information on what properties and functions are included: https://github.com/isene/Ruby-Curses-Class-Extension. The curses_template.rb is also installed in the lib directory and serves as the basis for my own curses applications. New in 3.0: Major rewrite. Lots of changes/improvements. 3.0.2: Path fix'
  s.authors     = ["Geir Isene"]
  s.email       = 'g@isene.com'
  s.files       = ["lib/curses-extension.rb", "lib/curses-template.rb", "README.md"]
  s.add_runtime_dependency 'curses', '~> 1.3', '>= 1.3.2'
  s.homepage    = 'https://isene.com/'
  s.metadata    = { "source_code_uri" => "https://github.com/isene/Ruby-Curses-Class-Extension" }
end
