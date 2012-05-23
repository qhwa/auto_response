require_relative 'helper'

class TestRespondWithArray < Test::Unit::TestCase

  include ARProxyTest

  def test_respond_with_good_status_array
    @ar.add_rule 'http://www.test.com/' => [200, nil, 'test']
    @req.start('www.test.com') do |http|
      http.request_get('/') do |res|
        assert_equal( nil, res.header["test"])
        assert_equal 'test', res.body
        assert_equal "200", res.code
      end
    end
  end

  def test_respond_with_404_status_array
    @ar.add_rule 'http://www.1688.com' => [404, nil, 'test']
    @req.start('www.1688.com') do |http|
      http.request_get('/') do |res|
        assert_equal( nil, res.header["test"])
        assert_equal 'test', res.body
        assert_equal "404", res.code
      end
    end
  end

end
