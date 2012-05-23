require_relative 'helper'

class TestRespondWithURL < Test::Unit::TestCase

  def setup
    @ar = start_proxy_server('0.0.0.0', 8765)
    @req = Net::HTTP::Proxy('0.0.0.0', 8765)
    sleep 0.1
  end

  def teardown
    stop_proxy_server
  end

  def test_respond_with_simple_file
    @ar.add_rule 'http://www.test.com/' => '=GOTO=> http://www.1688.com/crossdomain.xml'
    @req.start('www.test.com') do |http|
      http.request_get('/') do |res|
        open("http://www.1688.com/crossdomain.xml") do |file|
          assert_equal file.read, res.read_body
        end
      end
    end
  end

end
