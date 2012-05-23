require_relative 'helper'

class ParserTest < Test::Unit::TestCase

  include AutoResp::Parser

  def test_parse_only_body
    headers, body = parse("test")
    assert_equal nil, headers
    assert_equal "test", body
  end

  def test_parse_only_header
    headers, body = parse("test: good\n\n")
    assert_equal({"test" => "good"}, headers)
    assert body.empty?
  end

  def test_parse_header
    headers, body = parse("test: good\n\ncontent")
    assert_equal({"test"=>"good"}, headers)
    assert_equal "content", body
  end

  def test_first_line_empty
    headers, body = parse("  \ntest: good\n\ncontent")
    assert_equal nil, headers
    assert_equal "  \ntest: good\n\ncontent", body
  end

  def test_empty_line_in_middle
    response = %Q(server: autoresponder\ntest: hello\n  \ntest)
    headers, body = parse(response)
    assert_equal({"server" => "autoresponder", "test" => "hello"}, headers)
    assert_equal "test", body
  end

end
