require 'test/unit'
require 'net/http'
require_relative '../lib/autoresponse'

FIXTURE = File.expand_path("fixture", File.dirname(__FILE__))

def start_proxy_server(host, port)
  @arpid.join if @arpid
  @ar = AutoResp::AutoResponder.new :host => host, :port => port
  Thread.new { @ar.start }
  @ar
end

def stop_proxy_server
  @ar.stop
end
