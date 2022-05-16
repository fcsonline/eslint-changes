lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eslint/changes/version'

Gem::Specification.new do |spec|
  spec.name          = 'eslint-changes'
  spec.version       = Eslint::Changes::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.5.0'
  spec.authors       = ['Ferran Basora']
  spec.email         = ['fcsonline@gmail.com']

  spec.summary       = 'Eslint on changed lines from git fork point'
  spec.description   = <<-DESCRIPTION
    eslint-changes will run eslint on changed lines from forked point in your main branch.
    It will not complain about existing offenses in master branch on your git prioject.
    This gem is perfect as a Continuous Integration tool
  DESCRIPTION

  spec.homepage      = 'https://rubygems.org/gems/eslint-changes'
  spec.license       = 'MIT'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/fcsonline/eslint-changes',
    'bug_tracker_uri' => 'https://github.com/fcsonline/eslint-changes/issues'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'git_diff_parser', '~> 3.2'
  spec.add_runtime_dependency 'colorize', '~> 0.8.1'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
