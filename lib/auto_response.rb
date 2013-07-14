require 'xmlrpc/httpserver'
require 'open-uri'
require 'fileutils'
require 'listen'
require 'colorize'
require 'logger'

$: << File.expand_path( File.dirname(__FILE__) )

require 'ar/version'
require 'ar/proxy_server'
require 'ar/rule_manager'
require 'ar/parser'
require 'ar/session_viewer'

module AutoResp


  class AutoResponder

    ARHOME = "#{ENV["HOME"]}/.auto_response"
    RULES = "#{ARHOME}/rules"

    def initialize(config={})
      @config = config
      @rule_manager = RuleManager.new
      @logger = Logger.new( $stderr, Logger::WARN )
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
        self,
        :BindAddress  => @config[:host] || '0.0.0.0',
        :Port         => @config[:port] || 9000,
        :logger       => @logger
      )
      trap('INT') { stop_and_exit }
    end

    def start_proxy
      @proxy_thread = Thread.new { @server.start }
    end

    def start_viewer
      @viewer_thread = Thread.new {}
      SessionViewer.new( @server ).run 
    end

    public
    def start
      start_proxy
      start_viewer
    end

    def stop_and_exit
      stop
      exit
    end

    def stop
      @logger.info "\nshuting down"
      @server.shutdown
      @viewer_thread.kill
      @proxy_thread.kill
    end

    def add_rule(*args, &block)
      case args.first
      when Hash
        rules.merge! args.first
      when String
        rules[args[0]] = args[1]
      when Regexp
        if block_given?
          rules[args[0]] = block
        else
          rules[args[0]] = args[1]
        end
      end
    end

    def rules
      @rule_manager.rules
    end

    def clear_rules
      rules.clear
    end

    private
    def load_rules(path=nil)
      path ||= @config[:rule_config]
      path ||= "#{ARHOME}/rules"
      if File.readable?(path)
        @rule_manager.instance_eval File.read(path)
      end
      log_rules
    end

    def log_rules
      @logger.info "mapping rules:"
      rules.each do |n,v|
        @logger.info "\n" << n.to_s.ljust(30).green << "\n=> #{v}"
      end
    end

    def monitor_rules_change
      listener = Listen.to(ARHOME)
      listener.change { reload_rules }
      Thread.new { listener.start }
    end

    def reload_rules
      @rule_manager.clear
      load_rules
    end

  end

end

