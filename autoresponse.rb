require 'xmlrpc/httpserver'
require 'open-uri'

$port = 8888

$rules = [
  ['http://www.baidu.com', 'http://www.163.com'],
  ['http://www.google.com', '/home/bencode/Desktop/abc.txt'],
  ['http://kunmingkem.cn.alibaba.com', '/home/bencode/webroot/static/201107/25-wpp4poffer/demo2.htm']
]


class SimpleHandler

  def request_handler(request, response)
    header = request.header

    url = request.path
    puts "request url: #{url}"

    mapurl = filter_url(url)
    if url != mapurl
      puts "#{url} --> #{mapurl}"
    end
    
    open(mapurl) do |io|
      response.body = io.read
    end
  end
  
  def ip_auth_handler(io)
    true
  end

  def filter_url(url)
    $rules.each do |part|
      return part[1] if part[0] === url.sub(/\/$/, '')
    end
    url
  end
end

handler = SimpleHandler.new
server = HttpServer.new(handler, $port)
server.start.join
