require 'webrick/httpproxy'
require 'logger'
require 'ptools'

require_relative 'rule_manager'
require_relative 'parser'

module AutoResp

  class ProxyServer < WEBrick::HTTPProxyServer
    
    include Parser
    attr_reader :sessions

    def initialize(core, config={})
      @core = core
      super(config.update({
        :AccessLog  => [],
        :Logger     => WEBrick::Log.new("/dev/null")
      }))
      @sessions = []
      @ar_logger = config[:logger] || Logger.new
    end

    def service(req, res)
      logger.info "[#{req.unparsed_uri}]"
      info = { start: Time.now }

      before_filters.each do |block|
        if block.call( req, res ) == false
          super req, res
          return
        end
      end

      begin
        header, body, status = find_auto_res(req.unparsed_uri)
      rescue => e
        header = {}
        body   = <<-MSG
          ERROR:
            #{e.message}
            #{e.backtrace.join "\n"}
          MSG
        status = 500
      end

      res.status = status if status

      if @rule

        logger.debug "match".ljust(8)   << ": #{req.unparsed_uri}"
        logger.debug "header".ljust(8)  << ": #{header}"
        logger.debug "body".ljust(8)    << ": \n#{body[0..200]}#{'...' if body.size > 200}"
        logger.debug "-"*50

        res['x-auto-response-condition']  = @rule.first.to_s
        res['x-auto-response-with']       = @rule.last.to_s

        if header
          header.each do |k,v|
            v = v.join("\n") if v.respond_to?(:join)
            res[k] = v
          end
        end
        res.body = body
        info[:matched] = true
      else
        super(req, res)
      end

      info[:end] = Time.now
      sessions << [req, res, info]
    end

    def before_filters
      @before_filters ||= []
    end

    def before_filter(&block)
      logger.info "add before_filter".green
      before_filters << block
    end

    def clear_before_filters
      @before_filters.clear
    end

    def find_auto_res(url)
      rule = @core.rules.find do |condition, map_to|
        matched? url, condition
      end
          
      @rule = rule
      if rule
        condition, handlers = *rule
        handlers = [handlers] unless handlers.is_a?(Array)
        handlers.each {|proc| proc.call if proc.respond_to?(:call) }
        fetch(handlers.last, condition, url)
      end
    end

    def matched?( url, rule )
      trim_url(rule) === trim_url(url)
    end

    def fetch(handler, declare, uri)

      case handler
      when nil
        Net::HTTP.get_response(URI(uri)) do |res|
          return [res.to_hash, res.read_body, res.code]
        end
      when Proc
        if Regexp === declare
          mtc = uri.match(declare) 
          fetch( handler.call(*mtc), declare, uri )
        else
          fetch( handler.call, declare, uri )
        end
      when String
        if goto = redirect_path(handler)
          if is_uri?(goto)
            Net::HTTP.get_response(URI(goto)) do |res|
              return [res.to_hash, res.read_body, res.code]
            end
          else
            file = File.expand_path( goto )
            if File.exist?(file)
              content = IO.read file
              if File.binary? file
                return [nil, content, 200]
              else
                return parse(content)
              end
            end
          end
        else
          parse(handler)
        end
      when Fixnum
        [{}, "", handler]
      when Array
        [handler[1], handler[2], handler[0]]
      end
    end

    private
    def redirect_path(t)
      if is_single_line?(t)
        (t.match(/^=GOTO=> (\S.*?)\s*$/) || [] )[1]
      end
    end

    def is_uri?(txt)
      /^[A-Za-z][A-Za-z0-9+\-\.]*:\/\/.+/ =~ txt
    end

    def header_hash(header)
      h = header.to_hash
      h.each do |n,v|
        h[n] = v.join if Array === v
      end
    end

    def trim_url(url)
      if url.is_a? String
        url.sub(/\/$/, '')
      else
        url
      end
    end

    def is_single_line?(text)
      text.count("\n") < 2
    end

    def logger
      @ar_logger
    end

  end

end
