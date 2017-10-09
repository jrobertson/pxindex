Gem::Specification.new do |s|
  s.name = 'pxindex'
  s.version = '0.1.2'
  s.summary = 'Experimental gem to facilitate a keyword search, by querying a Polyrex document representing a hierarchical lookup table'
  s.authors = ['James Robertson']
  s.files = Dir['lib/pxindex.rb']
  s.add_runtime_dependency('polyrex-headings', '~> 0.1', '>=0.1.9')
  s.signing_key = '../privatekeys/pxindex.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/pxindex'
end
