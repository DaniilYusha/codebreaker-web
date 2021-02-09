require_relative 'autoload'

use Rack::Reloader if ENV.fetch('RACK_ENV', 'development') == 'development'
use Rack::Static, urls: %w[/bootstrap /jquery], root: 'node_modules'
use Rack::Static, urls: ['/assets'], root: 'views'
use Rack::Session::Cookie, key: ENV.fetch('COOKIE_KEY', 'key'),
                           secret: ENV.fetch('COOKIE_SECRET_KEY', 'secret_key')
use RackSessionAccess::Middleware unless ENV.fetch('RACK_ENV', 'development') == 'production'

run CodebreakerWeb::WebApplication
