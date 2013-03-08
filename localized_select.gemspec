# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'localized_select/version'

Gem::Specification.new do |gem|
  gem.name          = "localized_select"
  gem.version       = LocalizedSelect::VERSION
  gem.authors       = ["Herman verschooten"]
  gem.email         = ["Herman@verschooten.net"]
  gem.description   = %q{Localed Select Rails Form Helper}
  gem.summary       = %q{Generate a select using translations found in your locale yaml-files}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
