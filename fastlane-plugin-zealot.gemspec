# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/zealot/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-zealot'
  spec.version       = Fastlane::Zealot::VERSION
  spec.author        = 'icyleaf'
  spec.email         = 'icyleaf.cn@gmail.com'

  spec.summary       = 'Upload IPA/APK/dSYM/Proguard files to Zealot which it provides a self-host Over The Air Server for deployment of Android and iOS apps.'
  spec.homepage      = "https://github.com/getzealot/fastlane-plugin-zealot"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency 'faraday', '>= 1.0.1'
  spec.add_dependency 'fastlane-plugin-debug_file', '>= 0.3.0'

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.137.0')
end
