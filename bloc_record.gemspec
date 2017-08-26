Gem::Specification.new do |s|
  s.name          = 'bloc_record'
  s.version       = '0.0.1'
  s.date          = '2017-08-15'
  s.summary       = 'BlocRecord ORM'
  s.description   = 'An ActiveRecord-esque ORM adaptor'
  s.authors       = ['John Bennet Veloya']
  s.email         = 'bennetveloya@gmail.com'
  s.files         = Dir['lib/**/*.rb']
  s.require_paths = ["lib"]
  s.homepage      = 'http://rubygems.org/gems/bloc_record'
  s.license       = 'MIT'
  s.add_runtime_dependency 'sqlite3', '~> 1.3'
end
