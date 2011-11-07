module AutoResp

  module Parser

    require 'net/http'
    
    def parse(str)

      headers, body = {}, []
      to_find_header, body_start = true, false
      lines = str.lines
      #if lines[0] =~ /^\s*$/ or !(lines.any? {|l| l=})
        #to_find_header = false
      #end
      lines.each_with_index do |line, idx|
        if to_find_header and not body_start
          if line =~ /^\s*$/
            if idx == 0
              to_find_header = false
              body << line
            else
              body_start = true
              body = []
            end
          else
            body << line
            name, value = parse_header_item(line)
            if name
              headers[name] = value
            else
              to_find_header = false
            end
          end
        else
          body << line
        end
      end

      headers = nil unless to_find_header and body_start
      res_body = body.join

      [headers, res_body]
    end

    def parse_header_item(str)
      mtc = str.match /^\s*(\S+):\s*(\S*)\s*$/
      [mtc[1], mtc[2]] if mtc
    end


  end

end
