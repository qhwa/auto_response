module AutoResp
  module Helpers
    def url(target, &block)
      ::AutoResp.add_rule(target, &block);
    end

    def send(resp)
      ::AutoResp.add_handler( resp )
    end

    def send_file(path)
      redirect( path )
    end

    def redirect(url)
      ::AutoResp.add_handler '=GOTO=> ' << url
    end
  end
end

extend AutoResp::Helpers
