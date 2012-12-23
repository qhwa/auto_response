require_relative 'rule_dsl'

module AutoResp

  class RuleManager

    @@rules = {}

    class << self

      include RuleDSL

      def rules
        @@rules
      end

      def add_handler( handler )
        if @last_rule
          rules[@last_rule] = handler
        end
      end

      def add_rule(*args, &block)
        @last_rule = target = args.first
        case target
        when Hash
          @last_rule = target.keys.first
          rules.merge! target
        when String
          rules[target] = args[1]
        when Regexp
          if block_given?
            rules[target] = block
          else
            rules[target] = args[1]
          end
        end
      end

    end

  end

end
