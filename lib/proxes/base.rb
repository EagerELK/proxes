require 'tilt/haml'
require 'roda'
require 'rack'

module ProxES
  # Base Roda App
  class Base < Roda
    opts[:root] ||= File.expand_path(File.dirname(__FILE__) + '/../../')

    plugin :middleware

    use Rack::MethodOverride
    plugin :all_verbs

    plugin :default_headers,
      'Content-Type'=>'text/html',
      # 'Content-Security-Policy'=>"default-src 'self' https://oss.maxcdn.com/ https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com",
      #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
      'X-Frame-Options'=>'deny',
      'X-Content-Type-Options'=>'nosniff',
      'X-XSS-Protection'=>'1; mode=block'

    plugin :render, engine: 'haml', views: opts[:views]
    plugin :partials
    plugin :csrf, raise: true, skip_if: lambda { |r| !(r.path =~ %r{/_proxes/.*}) }
    plugin :indifferent_params
    plugin :flash
    plugin :halt
    plugin :public, root: opts[:public]

    plugin(:not_found) { view 'http_404' }
    plugin(:error_handler) do |e|
      case true
      when e.is_a?(Roda::RodaPlugins::Authentication::NotAuthenticated) || e.is_a?(OmniAuth::Error)
        request.redirect '/auth/identity'
      else
        logger.error e
        raise e unless ENV['RACK_ENV'] == 'production'
        view 'error', locals: { error: e }
      end
    end

    plugin :authentication
    plugin :pundit

    def logger
      require 'logger'
      @logger ||= Logger.new($stdout)
    end

    def root_url
      @root_url = opts[:root_url] || '/_proxes'
    end
  end
end
