require_relative 'helper'

class TestRespondWithFile < Test::Unit::TestCase

  def setup
    @ar = start_proxy_server('0.0.0.0', 8765)
    @req = Net::HTTP::Proxy('0.0.0.0', 8765)
    sleep 0.1
  end

  def teardown
    stop_proxy_server
  end

  def test_respond_with_simple_file
    @ar.deal 'http://www.test.com/' => '=> /etc/passwd'
    @req.start('www.test.com') do |http|
      http.request_get('/') do |res|
        assert_equal IO.read('/etc/passwd'), res.body
      end
    end
  end

end
