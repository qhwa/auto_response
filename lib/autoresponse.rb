require 'xmlrpc/httpserver'
require 'open-uri'
require_relative 'parser'

$rules = {
  'http://www.baidu.com' => 'http://www.163.com',
  'http://www.google.com' => '=> /etc/passwd',
  'http://kunmingkem.cn.alibaba.com' => '/home/bencode/webroot/static/201107/25-wpp4poffer/demo2.htm'
}

class AutoResponder
  
  def start(host='0.0.0.0', port=8888)
    handler = SimpleHandler.new
    @server = HttpServer.new(handler, port, host, 4, nil)
    @server.start.join
  end

  def stop
    @server.stop
    @server.join
  end

  def deal(*args)
    case args[0]
    when Hash
      args[0].each { |url, res| $rules[url] = res }
    when String
      $rules[args[0]] = args[1]
    end
  end

  alias_method :add_rule, :deal

end


class SimpleHandler

  def request_handler(request, response)
    url = request.path
    puts "request url: #{url}"

    data = find_response(url)
    if data
      headers, body = Parser.parse(data)
      response.header.update(headers) if headers
      response.body = fetch(body)
    else
      open(url) do |f|
        #TODO: add header support
        response.body = f.read
      end
    end
  end
  
  def ip_auth_handler(io)
    true
  end

  private
  def find_response(url)
    $rules.each do |tar,res|
      return res if tar.sub(/\/$/, '') === url.sub(/\/$/, '')
    end
    nil
  end

  def fetch(text)
    path = redirect_path(text)
    if path
      open(path) do |file|
        return file.read
      end
    end
    text
  end

  def redirect_path(body)
    mtc = body.match(/^=> (\S.*?)\s*$/)
    mtc[1] if mtc
  end


end

