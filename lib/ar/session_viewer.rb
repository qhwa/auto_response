require 'webrick/httpserver'

module AutoResp

  VIEWER_HOST = 'localhost'

  class SessionViewer

    def initialize( proxy_server )
      @proxy_server = proxy_server
    end

    def run
      root = File.expand_path('./viewer', File.dirname(__FILE__))
      WEBrick::HTTPServer.new({
        :BindAddress  => '0.0.0.0',
        :Port         => 9090,
        :AccessLog    => [],
        :Logger       => WEBrick::Log.new("/dev/null"),
        :DocumentRoot => root
      }).start
    end

  end

end
