require 'xmlrpc/httpserver'
require 'open-uri'
require_relative 'proxyserver'
require_relative 'parser'

module AutoResp
  class AutoResponder

    def initialize(config={})
      @server = ProxyServer.new(
        :BindAddress  => config[:host] || '0.0.0.0',
        :Port         => config[:port] || 9000
      )
      trap('INT') { stop }
    end
    
    def start
      @server.start
    end

    def stop
      @server.shutdown
    end

    def deal(*args)
      case args.first
      when Hash
        @server.resp_rules.merge! args.first
      when String
        @server.resp_rules[args[0]] = args[1]
      end
    end

    alias_method :add_rule, :deal

  end

end
