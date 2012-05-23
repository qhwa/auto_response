require 'xmlrpc/httpserver'
require 'open-uri'
require 'fileutils'
require 'rb-inotify'
require 'colorize'

require_relative 'ar/proxyserver'
require_relative 'ar/parser'
require_relative 'ar/rule_dsl'

module AutoResp

  @@rules = {}

  def self.rules; @@rules; end
  def self.add_rule( target, &block )
    @@last_rule = target
    @@rules[target] = block
  end

  def self.add_handler( handler )
    if @@last_rule
      @@rules[@@last_rule] = handler
    end
  end

  class AutoResponder

    ARHOME = "#{ENV["HOME"]}/.autoresponse"
    RULES = "#{ARHOME}/rules"

    def initialize(config={})
      @config = config
      init_autoresponse_home
      init_proxy_server
      load_rules
      monitor_rules_change
    end
    
    protected
    def init_autoresponse_home
      unless File.exist?(RULES)
        pwd = File.expand_path('..', File.dirname(__FILE__))
        FileUtils.mkdir_p(ARHOME) 
        FileUtils.cp "#{pwd}/rules.sample", RULES
      end
    end

    protected
    def init_proxy_server
      @server = ProxyServer.new(
        :BindAddress  => @config[:host] || '0.0.0.0',
        :Port         => @config[:port] || 9000
      )
      trap('INT') { stop_and_exit }
    end

    public
    def start
      @thread = Thread.new { @server.start }
      @thread.join
    end

    def stop_and_exit
      stop
      exit
    end

    def stop
      puts "\nshuting down"
      @server.shutdown
      @thread.exit if @thread
      Thread.main
    end

    def add_rule(*args, &block)
      case args.first
      when Hash
        @server.rules.merge! args.first
      when String
        @server.rules[args[0]] = args[1]
      when Regexp
        if block_given?
          @server.rules[args[0]] = block
        else
          @server.rules[args[0]] = args[1]
        end
      end
    end

    private
    def load_rules(path=nil)
      path ||= @config[:rule_config]
      path ||= "#{ARHOME}/rules"
      if File.readable?(path)
        load(path)
      end
      log_rules
    end

    def log_rules
      puts "mapping rules:"
      @server.rules.each do |n,v|
        puts n.to_s.ljust(30).green << "=> #{v}"
      end
    end

    def monitor_rules_change
      ntf = INotify::Notifier.new
      ntf.watch(RULES, :modify) { load_rules }
      Thread.new { ntf.run }
    end

  end

end

