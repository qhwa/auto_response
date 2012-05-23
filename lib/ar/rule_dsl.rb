module AutoResp
  module Helpers
    def url(target, &block)
      ::AutoResp.add_rule(target, &block);
    end

    def r(resp)
      ::AutoResp.add_handler( resp )
    end

    def goto(url)
      ::AutoResp.add_handler '=GOTO=> ' << url
    end
  end
end

extend AutoResp::Helpers
