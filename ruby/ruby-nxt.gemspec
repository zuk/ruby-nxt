require 'rake'

Gem::Specification.new do |s|
  s.name = %q{ruby-nxt}
  s.version = "0.8.0"
  s.date = %q{2006-09-26}
  s.summary = %q{Ruby interface for controlling the Lego Mindstorms NXT robotics kit via Bluetooth.}
  s.email = %q{matt@roughest.net}
  s.homepage = %q{http://rubyforge.org/projects/ruby-nxt}
  s.rubyforge_project = %q{ruby-nxt}
  s.description = %q{ruby-nxt is a Ruby interface for controlling the Lego Mindstorms NXT robotics kit via Bluetooth. The library currently provides low-level access to the NXT bytecode protocol as well as a nearly-complete high-level API for interacting with the NXT's motors, sensors, and other functions.}
  s.has_rdoc = true
  s.authors = ["Tony Buser", "Matt Zukowski"]
  s.files = FileList['*.rb', 'lib/**/*.rb', '[A-Z]*', 'test/**/*.rb']
  s.test_files = Dir['test/**/*_test.rb']
  s.rdoc_options = ["--title", "ruby-nxt #{s.version} RDocs", "--main", "README", "--line-numbers"]
  s.extra_rdoc_files = ["README", "LICENSE"]
# s.require_paths << '.' # in addition 'lib', which is the default require_paths
end
