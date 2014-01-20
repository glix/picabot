require File.dirname(__FILE__) << '/lib/picabot/version'

Gem::Specification.new do |s|
  s.name = 'picabot'
  s.version = Picabot::VERSION
  
  s.authors = 'George Timoschenko'
  s.email = 'somu@so.mu'
  s.homepage = 'http://github.com/somu/picabot'

  s.files = Dir['lib/**/*']
  s.executables = 'picabot'

  s.license = 'MIT'
  s.summary = 'GitHub image optimizer'
  s.description = 'Goes into every place on GitHub and optimizes repos.'

  s.add_dependency 'rest-client'
  s.add_dependency 'image_optim'
  s.add_dependency 'moneta'
  s.add_dependency 'git'
end
