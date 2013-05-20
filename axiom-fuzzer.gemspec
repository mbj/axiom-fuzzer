# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name     = 'axiom-fuzzer'
  s.version  = '0.0.1'

  s.authors  = ['Markus Schirp']
  s.email    = 'mbj@seonic.net'
  s.summary  = 'A fuzzer for axiom relations'
  s.homepage = 'http://github.com/mbj/axiom-fuzzer'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.require_paths    = %w(lib)
  s.extra_rdoc_files = %w(README.md)

  s.add_dependency('axiom',          '~> 0.1.0')
  s.add_dependency('adamantium',     '~> 0.0.7')
  s.add_dependency('equalizer',      '~> 0.0.4')
  s.add_dependency('abstract_type',  '~> 0.0.4')
  s.add_dependency('concord',        '~> 0.1.0')
  s.add_dependency('diffy',          '~> 2.1.3')
  s.add_dependency('terminal-table', '~> 1.4.5')
end
