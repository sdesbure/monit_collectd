# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monit_collectd/version'

Gem::Specification.new do |gem|
  gem.name          = "monit_collectd"
  gem.version       = MonitCollectd::VERSION
  gem.authors       = ["Sylvain Desbureaux"]
  gem.email         = ["sylvain.desbureaux@orange.com"]
  gem.description   = %q{a little application which retrieve values from a Monit instance and send them to Collectd}
  gem.summary       = %q{a little application which retrieve values from a Monit instance and send them to Collectd}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "monit"
  gem.add_runtime_dependency "collectd"
  gem.add_runtime_dependency "eventmachine"
end
