require 'xmlrpc/httpserver'
require 'open-uri'
require 'fileutils'
require 'rb-inotify'
require 'colorize'

require_relative 'ar/proxyserver'
require_relative 'ar/rule_manager'
require_relative 'ar/parser'

module AutoResp


  class AutoResponder

    ARHOME = "#{ENV["HOME"]}/.autoresponse"
    RULES = "#{ARHOME}/rules"

    def initialize(config={})
      @config = config
      @rule_manager = RuleManager.new
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
      @thread.kill
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
      puts "mapping rules:"
      rules.each do |n,v|
        puts n.to_s.ljust(30).green << "=> #{v}"
      end
    end

    def monitor_rules_change
      ntf = INotify::Notifier.new
      ntf.watch(RULES, :modify) { reload_rules }
      Thread.new { ntf.run }
    end

    def reload_rules
      @rule_manager.clear
      load_rules
    end

  end

end

