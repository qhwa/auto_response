# Ensure we require the local version and not one we might have installed already
require File.join( File.dirname(__FILE__),'lib/ar/version.rb')
spec = Gem::Specification.new do |s| 
  s.name = 'auto_response'
  s.description = <<-EOF
    HTTP debugging made easy.
  EOF
  s.version  = AutoResp::VERSION
  s.author   = 'qhwa'
  s.email    = 'qhwa@163.com'
  s.homepage = 'https://github.com/qhwa/auto_response'
  s.platform = Gem::Platform::RUBY
  s.summary  = 'HTTP debugging tool'
  # Add your other files here if you make them
  s.files    = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = false
  s.bindir   = 'bin'
  s.executables << 'auto_resp'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_runtime_dependency %q<listen>,      "~> 2.0"
  s.add_runtime_dependency %q<colorize>,    ">= 0"
  s.add_runtime_dependency %q<daemons>,     "~> 1.1.9"
  s.add_runtime_dependency %q<string_utf8>, ">= 0"
  s.add_runtime_dependency %q<rb-inotify>,  "~> 0.9"
  s.add_runtime_dependency %q<ptools>,      ">= 0"
end
