module AutoResp

  module RuleDSL
    def url(target, &block)
      add_rule(target, &block);
    end

    def r(resp)
      add_handler( resp )
    end

    def goto(url)
      add_handler '=GOTO=> ' << url
    end
  end
end
