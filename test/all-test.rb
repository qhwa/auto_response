gem 'test-unit'
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

require_relative 'respond_with_file_test'
require_relative 'respond_with_string_test'
require_relative 'respond_with_url_test'
require_relative 'response_text_parser_test'

class ALLTests < Test::Unit::TestSuite

  def self.suite
    tests = Test::Unit::TestSuite.new

    tests << ParserTest.suite
    tests << TestRespondWithString.suite
    tests << TestRespondWithFile.suite
    tests << TestRespondWithURL.suite
    
    tests
  end
end


Test::Unit::UI::Console::TestRunner.run( ALLTests )
