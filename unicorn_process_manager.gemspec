# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "unicorn_process_manager"
  spec.version       = "0.0.5"
  spec.authors       = ["Spring_MT"]
  spec.email         = ["today.is.sky.blue.sky@gmail.com"]
  spec.summary       = %q{manage unicorn [start|stop|restart|reopen_log] for rails + capistrano}
  spec.homepage      = "https://github.com/SpringMT/unicorn_process_manager"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.description = <<description
manage unicorn [start|stop|restart|reopen_log] for rails + capistrano
description

end
