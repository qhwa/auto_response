require 'webrick/httpproxy'
require 'logger'

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

      header, body, status = find_auto_res(req.unparsed_uri)
      res.status = status if status

      if header or body

        logger.debug "match".ljust(8)   << ": #{req.unparsed_uri}"
        logger.debug "header".ljust(8)  << ": #{header}"
        logger.debug "body".ljust(8)    << ": \n#{body}"
        logger.debug "-"*50

        res.header.merge!(header || {})
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
      @core.rules.find do |tar, map|
        if trim_url(tar) === trim_url(url)
          return fetch(map, tar, url)
        end
      end
    end

    def fetch(txt, declare, uri)

      case txt
      when Proc
        mtc = uri.match(declare) if Regexp === declare
        fetch( txt.call(*mtc), declare, uri )
      when String
        if goto = redirect_path(txt)
          if is_uri?(goto)
            Net::HTTP.get_response(URI(goto)) do |res|
              return [nil, res.body]
            end
          elsif File.exist?(goto)
            return parse(IO.read(goto))
          end
        else
          parse(txt)
        end
      when Fixnum
        [{}, "", txt]
      when Array
        [txt[1], txt[2], txt[0]]
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
