require 'sinatra/base'
require 'haml'

module AutoResp

  class SessionViewer < Sinatra::Base

    class << self
      attr_accessor :proxy_server
    end

    set :views, File.join(settings.root, 'viewer/tmpl')

    get '/' do
      haml :index
    end

    before('/') do
      @sessions = SessionViewer.proxy_server.sessions.dup
    end

  end

end
