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
      @resp_rules = {}
    end

    def service(req, res)
      header, body = find_auto_res(req.unparsed_uri)
      if header or body
        puts "match".ljust(8) << ": #{req.unparsed_uri}"
        puts "header".ljust(8) << ": #{header}"
        puts "body".ljust(8) << ": \n#{body}"
        puts "-"*50
        res.header.merge!(header || {})
        res.body = body
      else
        super(req, res)
      end
    end

    def find_auto_res(url)
      @resp_rules.find do |tar,map|
        if tar.sub(/\/$/, '') === url.sub(/\/$/, '')
          return fetch(map)
        end
      end
    end

    def fetch(txt)
      if txt.count("\n") < 2
        if goto = redirect_path(txt)
          if is_uri?(goto)
            Net::HTTP.get_response(URI(goto)) do |res|
              return [header_hash(res.header), res.body]
            end
          elsif File.exist?(goto)
            return parse(IO.read(goto))
          end
        end
      end
      parse(txt)
    end

    private
    def redirect_path(t)
      (t.match(/^=> (\S.*?)\s*$/) || [] )[1]
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

  end

end
