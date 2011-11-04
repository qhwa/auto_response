require 'test/unit'
require 'net/http'
require_relative '../lib/autoresponse'

def start_proxy_server(host, port)
  ar = AutoResponder.new
  @t = Thread.new do
    ar.start(host, port)
    def at_exit
      ar.stop
    end
  end
  sleep 0.1
  ar
end

def stop_proxy_server
  Thread.kill @t
end
