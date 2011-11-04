class Parser
  
  def self.parse(str)
    headers = {}
    body = []
    to_find_header = true
    header_end = false
    str.split("\n").each_with_index do |line, idx|
      if to_find_header and not header_end
        if line =~ /^\s*$/
          if idx == 0
            to_find_header = false
            body << line
          else
            header_end = true
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

    headers = nil unless to_find_header and header_end
    [headers, body.join("\n")]
  end

  def self.parse_header_item(str)
    mtc = str.match /^\s*(\S+):\s*(\S*)\s*$/
    [mtc[1], mtc[2]] if mtc
  end

end

