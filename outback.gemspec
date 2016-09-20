require_relative 'lib/outback/version'

Gem::Specification.new do |s|
  s.name          = 'outback'
  s.version       = Outback::VERSION
  s.date          = '2016-09-20'
  s.summary       = "Ruby Backup Tool"
  s.description   = "A Ruby backup tool"
  s.authors       = ['Matthias Grosser']
  s.email         = 'mtgrosser@gmx.net'
  s.licenses      = ['MIT']
  s.files         = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', 'README.md', 'CHANGELOG']
  s.require_path  = 'lib'
  s.homepage      = 'http://github.com/onrooby/outback'

  s.executables << 'outback'

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'net-sftp'
  s.add_dependency 's3', '>= 0.3.24'
end
