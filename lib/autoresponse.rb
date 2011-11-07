require 'xmlrpc/httpserver'
require 'open-uri'
require 'fileutils'
require_relative 'proxyserver'
require_relative 'parser'

module AutoResp

  def self.set_rules(r)
    @@rules = r
  end

  def self.rules
    @@rules || {}
  end

  class AutoResponder

    ARHOME = "#{ENV["HOME"]}/.autoresponse"

    def initialize(config={})
      @config = config
      init_home
      @server = ProxyServer.new(
        :BindAddress  => config[:host] || '0.0.0.0',
        :Port         => config[:port] || 9000
      )
      trap('INT') { stop }
      
      load_rules
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

    protected
    def init_home
      FileUtils.mkdir_p(ARHOME)
      pwd = File.expand_path(File.dirname(__FILE__))
      unless File.exist?("#{ARHOME}/rules")
        FileUtils.cp "#{pwd}/rules.sample", "#{ARHOME}/rules"
      end
    end

    def load_rules(path=nil)
      path ||= (@config[:rule_config] || "#{ARHOME}/rules")
      if File.readable?(path)
        load(path)
        @server.resp_rules.merge! AutoResp.rules
      end
      log_rules
    end

    def log_rules
      puts "mapping rules:"
      @server.resp_rules.each do |n,v|
        puts n.to_s.ljust(30) << "=> #{v}"
      end
    end

  end

end
