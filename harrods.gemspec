# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'harrods/version'

Gem::Specification.new do |gem|
  gem.name          = "harrods"
  gem.version       = Harrods::VERSION
  gem.authors       = ["John"]
  gem.email         = ["john@musicglue.com"]
  gem.description   = %q{How much does that cost?!}
  gem.summary       = %q{Method request pricing for MRI Railsexpress}
  gem.homepage      = "https://github.com/musicglue/harrods"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency "redis"
  gem.add_dependency "redis-namespace"
  gem.add_dependency "sinatra"
  gem.add_dependency "erubis"
  gem.add_dependency "daybreak"
  gem.add_dependency "colorize"

end
