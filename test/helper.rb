require 'test/unit'
require 'net/http'
require_relative '../lib/auto_response'

FIXTURE = File.expand_path("fixture", File.dirname(__FILE__))

module ARProxyTest

  def setup
    @ar = start_proxy_server('127.0.0.1', 8764)
    @req = Net::HTTP::Proxy('127.0.0.1', 8764)
  end

  def start_proxy_server(host, port)
    @ar = AutoResp::AutoResponder.new :host => host, :port => port
    Thread.new {
      @ar.start 
      @ar.clear_rules
    }
    sleep 0.1
    @ar
  end

  def teardown
    stop_proxy_server
  end

  def stop_proxy_server
    @ar.stop
  end
  
end
