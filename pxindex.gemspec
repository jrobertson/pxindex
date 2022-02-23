Gem::Specification.new do |s|
  s.name = 'pxindex'
  s.version = '0.3.0'
  s.summary = 'Experimental gem to facilitate a keyword search, ' + 
      'by querying a Polyrex document representing a hierarchical lookup table'
  s.authors = ['James Robertson']
  s.files = Dir['lib/pxindex.rb']
  s.add_runtime_dependency('nokogiri', '~> 1.13', '>=1.13.3')
  s.add_runtime_dependency('pxindex-builder', '~> 0.2', '>=0.2.1')
  s.add_runtime_dependency('polyrex-headings', '~> 0.3', '>=0.3.0')
  s.signing_key = '../privatekeys/pxindex.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/pxindex'
end
