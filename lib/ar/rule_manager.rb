require_relative 'rule_dsl'

module AutoResp

  class RuleManager

    include RuleDSL

    def initialize
    end

    def rules
      @rules ||= {}
    end

    def clear
      @rules.clear
    end

    def add_handler( handler )
      if @last_rule
        rules[@last_rule] ||= []
        rules[@last_rule] << handler
      end
    end

    def add_rule(*args, &block)
      @last_rule = target = args.first
      case target
      when Hash
        @last_rule = target.keys.first
        rules.merge! target
      when String, Regexp
        rules[target] = args[1]
      end
      rules[target] ||= block if block
    end

  end

end
