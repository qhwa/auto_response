require 'xmlrpc/httpserver'
require 'open-uri'
require 'yaml'
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
      load_rules(config[:config] || "#{ENV["HOME"]}/.autoresponse")
      puts "mapping rules:"
      @server.resp_rules.each do |n,v|
        puts n.to_s.ljust(50) << "=> #{v}"
      end
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

    def load_rules(path)
      if File.readable?(path)
        @server.resp_rules.merge! YAML.load_file(path)
      end
    end

  end

end
