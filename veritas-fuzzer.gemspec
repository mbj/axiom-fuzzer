# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name     = 'veritas-fuzzer'
  s.version  = '0.0.1'

  s.authors  = ['Markus Schirp']
  s.email    = 'mbj@seonic.net'
  s.summary  = 'A fuzzer for veritas relations'
  s.homepage = 'http://github.com/mbj/veritas-fuzzer'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.require_paths    = %w(lib)
  s.extra_rdoc_files = %w(README.md)

  s.add_dependency('veritas',        '~> 0.0.7')
  s.add_dependency('adamantium',     '~> 0.0.6')
  s.add_dependency('equalizer',      '~> 0.0.4')
  s.add_dependency('abstract_type',  '~> 0.0.4')
  s.add_dependency('composition',    '~> 0.0.1')
  s.add_dependency('diffy',          '~> 2.1.3')
  s.add_dependency('terminal-table', '~> 1.4.5')
end
