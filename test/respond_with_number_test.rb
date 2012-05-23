require_relative 'helper'

class TestRespondWithStatusCode < Test::Unit::TestCase

  include ARProxyTest

  def test_respond_with_500
    @ar.add_rule 'http://www.163.com/' => 500
    @req.start('www.163.com') do |http|
      http.request_get('/') do |res|
        assert_equal "500", res.code
      end
    end
  end

  def test_respond_with_404
    @ar.add_rule 'http://www.163.com' => 404
    @req.start('www.163.com') do |http|
      http.request_get('/') do |res|
        assert_equal "404", res.code
      end
    end
  end

end
