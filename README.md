axiom-fuzzer
==============

[![Build Status](https://secure.travis-ci.org/mbj/axiom-fuzzer.png?branch=master)](http://travis-ci.org/mbj/axiom-fuzzer)
[![Dependency Status](https://gemnasium.com/mbj/axiom-fuzzer.png)](https://gemnasium.com/mbj/axiom-fuzzer)
[![Code Climate](https://codeclimate.com/github/mbj/axiom-fuzzer.png)](https://codeclimate.com/github/mbj/axiom-fuzzer)

Fuzzer for axiom relations

Rationale
---------

The fuzzer will generate randomly structured axiom relation trees. These trees will get executed in-memory and via
the database adapter. In case there are any differences, one part of the implementation is doing something nasty and
might contain a bug.

Usage
-----

The fuzzer is in spike mode, only [axiom-arango-adapter](https://github.com/mbj/axiom-arango-adapter) uses it in the current form.
Instructions to use it with this adapter can be found in the adapters [README](https://github.com/mbj/axiom-arango-adapter#fuzzer).

Installation
------------

There is currently no gem release. Use git source in your Gemfile:

```ruby
gem 'composition',    :git => 'https://github.com/mbj/composition.git'
gem 'axiom-fuzzer', :git => 'https://github.com/mbj/axiom-fuzzer.git'
```

Credits
-------

* [Markus Schirp (mbj)](https://github.com/mbj) Author

Contributing
-------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile or version
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------

See `LICENSE` file.
