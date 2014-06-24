# AutoResponse - HTTP debugging tool for Linux and Mac

## What's auto_response for?

[Fiddler](http://www.fiddler2.com) is the favor tool of many web developers for debugging HTTP web apps. However it is only available on Windows. AutoResponse ports the most used feature of fiddler, 'auto respond', to Linux and Mac world.

Auto_response acts as a proxy server like Fiddler does, allowing you to modify the content of HTTP response.

## Quick start

1. requirements
    - \*nix system, Mac/Linux
    - ruby 1.9+ (may work on 1.8.7, but not very well tested)

1. Install and run

    ~~~sh
    gem install 'auto_response'
    auto_resp start

    auto_resp status #check server status
    auto_resp stop   #stop proxy server
    ~~~

2. Set your browser proxy to 'http://127.0.0.1:9000'
3. Edit the configuration file to modify the urls you want change the response.

    By default, the configuration file is located at:
    `$HOME/.auto_response/rules`

## Response rules

~~~ruby
# Examples:
 
# just respond with status number
url "http://www.catchme.com"
r 404

# if you want to respond all requests with url 
# equals "http://www.1688.com" with "Hello world!" :
url "http://www.1688.com" 
r "Hello world" 

# or you can respond with Array
url "http://china.alibaba.com"
r [200, {}, "Got replaced"] #[status, header, body]

# if you want to respond these requests with a file:
# this url will be responded with content of somefile.txt
# you can set headers and body in 'somefile.txt'
url "http://www.yousite.com" 
goto "/home/youruser/somefile.txt"

# redirect to another url
url "http://www.targetsite.com" 
goto "http://www.real-request-target.com/test.html"

# respond with text setting headers
url "http://www.target-site.com/target-url"
r <<-RESP
    Test-Msg      : http-header-example
    header-server : Auto-Responder
    Content-Type  : text/html; charset=utf-8

    <!Doctype html>
    <html><body><h1>Hello world!</h1></body></html>
  RESP

# match with regexp
url %r{http://pnq\.cc}
r "Any request made to pnq.cc will be responded with this message."

# regular expression and params
url %r{http://anysite\.cc(.*)} do |uri, path|
  <<-RESP
    Content-Type  : text/html; charset=utf-8

    <style>
      body { font-size: 50pt; }
      em { color: #ff7300; }
      small { color: #ccc; }
    </style>

    With regular expression, you can do more powerful things.  <br/> 
    You're requesting <em>#{path}</em> <br/>
    <small>Server time is #{Time.now} now. </small>
    RESP
end

# delay every images with 1 second
url %r{\.(jpe?g|gif|png)$}
delay 1

# use `delay` together with other response, just simple:
url "http://www.delayed.com"
delay 10
r "Delayed with 10 seconds"
~~~

## TODO:
* GUI monitor showing sessions
