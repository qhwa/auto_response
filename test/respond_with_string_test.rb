require_relative 'helper'

class TestRespondWithString < Test::Unit::TestCase

  def setup
    @ar = start_proxy_server('127.0.0.1', 8765)
    @req = Net::HTTP::Proxy('127.0.0.1', 8765)
    sleep 0.1
  end

  def teardown
    stop_proxy_server
  end

  def test_respond_with_simple_string
    @ar.deal 'http://www.test.com/' => 'test'
    @req.start('www.test.com') do |http|
      http.request_get('/') do |res|
        assert_equal( nil, res.header["test"])
        assert_equal 'test', res.body
      end
    end
  end

  def test_respond_with_header_and_body
    response = %Q(server: autoresponder\nname: hello\n  \ntest)
    @ar.deal 'http://www.1688.com/test' => response
    @req.start('www.1688.com') do |http|
      http.request_get('/test') do |res|
        assert_equal( "autoresponder", res.header["server"])
        assert_equal( "hello", res.header["name"])
        assert_equal 'test', res.body
      end
    end
  end

end
