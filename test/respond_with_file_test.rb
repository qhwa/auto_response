require_relative 'helper'

class TestRespondWithFile < Test::Unit::TestCase

  include ARProxyTest

  def test_respond_with_simple_file
    @ar.add_rule 'http://www.test.com/' => "=GOTO=> #{FIXTURE}/passwd"
    @req.start('www.test.com') do |http|
      http.request_get('/') do |res|
        assert_equal IO.read("#{FIXTURE}/passwd"), res.body
      end
    end
  end

end
