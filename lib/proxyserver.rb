require 'webrick/httpproxy'
require 'webrick/log'

require_relative 'parser'

module AutoResp

  class ProxyServer < WEBrick::HTTPProxyServer
    
    include Parser

    attr_accessor :resp_rules

    def initialize(config={})
      super(config.update({
        :AccessLog  => [],
        :Logger     => WEBrick::Log.new("/dev/null")
      }))
    end

    def response_rules
      ::AutoResp.rules || {}
    end

    alias_method :rules, :response_rules

    def service(req, res)
      header, body, status = find_auto_res(req.unparsed_uri)
      res.status = status if status
      if header or body
        puts "match".ljust(8)   << ": #{req.unparsed_uri}"
        puts "header".ljust(8)  << ": #{header}"
        puts "body".ljust(8)    << ": \n#{body}"
        puts "-"*50
        res.header.merge!(header || {})
        res.body = body
      else
        super(req, res)
      end
    end

    def find_auto_res(url)
      response_rules.find do |tar, map|
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
        [nil, nil, txt]
      when Array
        p [txt[1], txt[2], txt[0]]
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

  end

end
