lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift lib  unless ($LOAD_PATH.include? lib)
require 'AdventureRL/version'
github_url = 'https://github.com/Noah2610/AdventureRL'

Gem::Specification.new do |spec|
  spec.name          = 'adventure_rl'
  spec.version       = AdventureRL::VERSION
  spec.authors       = ['Noah Rosenzweig']
  spec.email         = ['rosenzweig.noah@gmail.com']
  spec.summary       = <<-SUMMARY_END
  Game framework built on top of Gosu.
  SUMMARY_END
  spec.description   = <<-DESCRIPTION_END
  This video game framework is written using the Gosu game development library.
  It was originally intended to be used for writing Point-N-Click adventure games,
  but has become a more general 2D video game framework.
  It's interesting features include video and audio playback capabilities.
  The project is definitely lacking some documentation.
  Although I have been trying to write documentation using rdoc and write tests
  with Minitest, I do not think that I have been doing either of those very successfully.
  I don't think many people aside from myself will be able to use it properly,
  as I have built it specifically for my needs.
  Thank you for reading, have a nice day :)
  DESCRIPTION_END
  spec.homepage      = github_url
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler',  '~> 1.16'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'rdoc',     '~> 6.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'virb'

  spec.add_dependency             'gosu',     '~> 0.13.3'
end
