# frozen_string_literal: true

require_relative "lib/primesrs/version"

Gem::Specification.new do |spec|
  spec.name          = "primesrs"
  spec.version       = Primesrs::VERSION
  spec.authors       = ["Guillermo Lella"]
  spec.email         = ["arkorott@gmail.com"]
  spec.summary       = "Get list of primes until given integer limit."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")
  spec.add_dependency "ffi"
  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir['lib/**/*', 'src/**/*.rs', 'Cargo.toml', 'LICENSE', 'README.md']
  spec.require_paths = ["lib"]
end
