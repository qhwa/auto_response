require 'webrick/httpserver'
require 'ar/har'

module AutoResp

  class SessionViewer

    def initialize( proxy_server )
      @proxy_server = proxy_server
    end

    def run
      root = File.expand_path('./viewer', File.dirname(__FILE__))
      server = WEBrick::HTTPServer.new({
        :BindAddress  => '0.0.0.0',
        :Port         => 9090,
        :AccessLog    => [],
        :Logger       => WEBrick::Log.new("/dev/null"),
        :DocumentRoot => root
      })
      server.mount_proc '/sessions.har' do |req, res|
        res.body = HAR.sessions_to_har( @proxy_server.sessions )
      end
      server.start
    end

  end

end
