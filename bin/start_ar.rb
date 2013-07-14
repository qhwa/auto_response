unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.expand_path(path.to_str, File.dirname(caller[0]))
    end
  end
end

$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'auto_response'

AutoResp::AutoResponder.new.start
