# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pacioli/version'

Gem::Specification.new do |gem|
  gem.name          = "pacioli"
  gem.version       = Pacioli::VERSION
  gem.authors       = ["Jeffrey van Aswegen"]
  gem.email         = ["jeffmess@gmail.com"]
  gem.description   = %q{A double-entry bookkeeping system for Ruby on Rails}
  gem.summary       = %q{A double-entry bookkeeping system for Ruby on Rails}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport"
  gem.add_dependency "activerecord", "~> 3.0"
  gem.add_dependency "i18n"
  
  gem.add_development_dependency 'combustion', '~> 0.3.1'
end
