require_relative 'helper'

class TestRespondWithStatusCode < Test::Unit::TestCase

  def setup
    @ar = start_proxy_server('127.0.0.1', 8765)
    @req = Net::HTTP::Proxy('127.0.0.1', 8765)
    sleep 0.1
  end

  def teardown
    stop_proxy_server
  end

  def test_respond_with_200
    @ar.add_rule 'http://www.test.com/' => 200
    @req.start('www.test.com') do |http|
      http.request_get('/') do |res|
        assert_equal "200", res.code
      end
    end
  end

  def test_respond_with_404
    @ar.add_rule 'http://www.1688.com' => 404
    @req.start('www.1688.com') do |http|
      http.request_get('/') do |res|
        assert_equal "404", res.code
      end
    end
  end

end
