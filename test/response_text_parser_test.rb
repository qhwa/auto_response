require_relative 'helper'
require_relative '../lib/parser'

class ParserTest < Test::Unit::TestCase

  def test_parse_only_body
    headers, body = Parser.parse("test")
    assert_equal nil, headers
    assert_equal "test", body
  end

  def test_parse_only_header
    headers, body = Parser.parse("test: good\n\n")
    assert_equal nil, headers
    assert_equal "test: good", body
  end

  def test_parse_header
    headers, body = Parser.parse("test: good\n\ncontent")
    assert_equal({"test"=>"good"}, headers)
    assert_equal "content", body
  end

  def test_first_line_empty
    headers, body = Parser.parse("  \ntest: good\n\ncontent")
    assert_equal nil, headers
    assert_equal "  \ntest: good\n\ncontent", body
  end

  def test_first_line_empty
    response = %Q(server: autoresponder\ntest: hello\n  \ntest)
    headers, body = Parser.parse(response)
    assert_equal({"server" => "autoresponder", "test" => "hello"}, headers)
    assert_equal "test", body
  end

end
