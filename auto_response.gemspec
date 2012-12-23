# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "auto_response"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["qhwa"]
  s.date = "2012-12-23"
  s.email = "qhwa@163.com"
  s.executables = ["ar"]
  s.extra_rdoc_files = ["readme.md"]
  s.files = ["readme.md", "rules.sample", "Gemfile", "Gemfile.lock", "bin/start_ar.rb", "bin/ar", "test/all-test.rb", "test/response_text_parser_test.rb", "test/respond_with_number_test.rb", "test/respond_with_url_test.rb", "test/respond_with_string_test.rb", "test/respond_with_array_test.rb", "test/fixture", "test/fixture/passwd", "test/fixture/hello_world.txt", "test/respond_with_file_test.rb", "test/helper.rb", "test/match_with_reg_test.rb", "lib/autoresponse.rb", "lib/ar", "lib/ar/parser.rb", "lib/ar/proxyserver.rb", "lib/ar/rule_manager.rb", "lib/ar/rule_dsl.rb"]
  s.homepage = "https://github.com/qhwa/auto_resposne"
  s.rdoc_options = ["--main", "readme.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A proxy server for debugging HTTP requests."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
