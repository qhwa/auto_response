$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'auto_response'

AutoResp::AutoResponder.new.start
