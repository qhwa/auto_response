require 'rubygems'
gem 'test-unit'
require 'test/unit'
require 'test/unit/testsuite'
require 'test/unit/ui/console/testrunner'

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.expand_path(path.to_str, File.dirname(caller[0]))
    end
  end
end

require_relative 'respond_with_file_test'
require_relative 'respond_with_string_test'
require_relative 'respond_with_url_test'
require_relative 'respond_with_array_test'
require_relative 'respond_with_number_test'
require_relative 'match_with_reg_test'
require_relative 'response_text_parser_test'

class ALLTests < Test::Unit::TestSuite

  def self.suite
    tests = Test::Unit::TestSuite.new

    tests << ParserTest.suite
    tests << TestRespondWithString.suite
    tests << TestRespondWithFile.suite
    tests << TestRespondWithURL.suite
    tests << TestRespondWithArray.suite
    tests << TestRespondWithStatusCode.suite
    tests << TestMatchWithReg.suite
    
    tests
  end
end


Test::Unit::UI::Console::TestRunner.run( ALLTests )
