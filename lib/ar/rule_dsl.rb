module AutoResp
  module Helpers
    def url(target, &block)
      ::AutoResp::RuleManager.add_rule(target, &block);
    end

    def r(resp)
      ::AutoResp::RuleManager.add_handler( resp )
    end

    def goto(url)
      ::AutoResp::RuleManager.add_handler '=GOTO=> ' << url
    end
  end
end

extend AutoResp::Helpers
