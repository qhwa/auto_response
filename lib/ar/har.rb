require 'json'
require 'cgi'
require 'string/utf8'

module AutoResp

  class HAR
    
    class << self

      def sessions_to_har( sessions )
        har = {
          :log => {
            :version => '1.2',
            :creator => {
              :name     => 'auto_response',
              :version  => AutoResp::VERSION,
              :comment  => 'proxied by auto_response'
            },
            :pages => []
          }
        }
        har[:log][:entries] = sessions.map do |session|
          session_to_entry session
        end
        JSON.fast_generate har
      end

      def session_to_entry( session )
        req, res, info = *session
        {
          pageref:   nil,
          startedDateTime:  info[:start],
          time:     info[:end].to_i - info[:start].to_i,
          request:  request_data( req ),
          response: response_data( res ),
          cache:    cache_data( req, res ),

          #FIXME: add timing feature
          timings: {
            blocked:  0,
            dns:      -1,
            connect:  15,
            send:     20,
            wait:     38,
            receive:  12,
            ssl:      -1,
            comment: ""
          },

          serverIPAddress: req.host,
          #NOT implemented
          connection: '',
          comment:    info[:matched] ? 'x-auto-response' : nil
        }
      end

      def request_data( req )
        {
          method:       req.request_method,
          url:          req.unparsed_uri,
          httpVersion:  req.http_version,
          cookies:      req.cookies.map {|c| cookie_data( c ) },
          headers:      req.header.map { |h| header_data( h ) },
          queryString:  CGI.parse(req.query_string || ''),
          #TODO: parse post data
          postData: {},
          headersSize:  0,
          bodySize:     (req.body ? req.content_length : 0),
          comment:      nil
        }
      end

      def cookie_data( cookie )
        {
          name:     cookie.name,
          value:    cookie.value,
          path:     cookie.path,
          domain:   cookie.domain,
          expires:  cookie.expires,
          #FIXME: check httponly
          httpOnly: nil,
          secure:   cookie.secure,
          comment: nil
        }
      end

      def header_data( header )
        name, value = *header
        value = value.join("\n") if value.is_a?(Array)
        {
          name:   name,
          value:  value,
          comment: nil
        }
      end

      def response_data( res )
        body = res.body
        body.utf8!
        body = '**raw data**' unless body.valid_encoding?
        {
          status:       res.status,
          statusText:   res.message,

          httpVersion:  res.http_version,
          cookies:      res.cookies.map {|c| 
            cookie_data( WEBrick::Cookie.parse_set_cookie c) },
          headers:      res.header.map {|h| header_data(h) },
          content:      body,

          #FIXME
          redirectURL:  '',
          headerSize:   160,

          bodySize:     res.content_length,
          comment: nil
        }
      end

      def cache_data( req, res )
        {
          #FIXME
          beforeRequest: nil,
          afterRequest: nil
        }
      end

    end

  end

end
