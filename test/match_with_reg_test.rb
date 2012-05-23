require_relative 'helper'

class TestMatchWithReg < Test::Unit::TestCase

  def setup
    @ar = start_proxy_server('127.0.0.1', 8765)
    @req = Net::HTTP::Proxy('127.0.0.1', 8765)
    sleep 0.1
  end

  def teardown
    stop_proxy_server
  end

  def test_with_parts
    @ar.add_rule %r(http://books.cc/(.*)/(.*)) do |uri, cat, page|
      "cat: #{cat}; page: #{page}"
    end
    @req.start('books.cc') do |http|
      http.request_get('/books/1') do |res|
        assert_equal 'cat: books; page: 1', res.body
        assert_equal "200", res.code
      end
    end
  end

end
