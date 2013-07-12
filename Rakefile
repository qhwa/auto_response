require "rubygems"
require "rubygems/package_task"
require "rdoc/task"

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end


task :default => ["test"]

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "auto_response"
  s.version           = "0.1.6"
  s.summary           = "A proxy server for debugging HTTP requests. "
  s.author            = "qhwa"
  s.email             = "qhwa@163.com"
  s.homepage          = "https://github.com/qhwa/auto_response"

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(readme.md)
  s.rdoc_options      = %w(--main readme.md)

  # Add any extra files to include in the gem
  s.files             = %w(readme.md rules.sample Gemfile Gemfile.lock) + Dir.glob("{bin,test,lib}/**/*")
  s.executables       = "ar"
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("listen")
  s.add_dependency("colorize")
  s.add_dependency("daemons")

  # If your tests use any gems, include them here
  s.add_development_dependency("gem-this")
  s.add_development_dependency("test-unit")
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more 
# about that here: http://gemcutter.org/pages/gem_docs
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

# If you don't want to generate the .gemspec file, just remove this line. Reasons
# why you might want to generate a gemspec:
#  - using bundler with a git source
#  - building the gem without rake (i.e. gem build blah.gemspec)
#  - maybe others?
task :package => :gemspec

# Generate documentation
RDoc::Task.new do |rd|
  rd.main = "readme.md"
  rd.rdoc_files.include("readme.md", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end
