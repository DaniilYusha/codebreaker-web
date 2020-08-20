require_relative 'autoload'

use Rack::Reloader
use Rack::Static, urls: ['/app/assets']
use Rack::Session::Cookie, key: 'rack.session',
                           secret: 'secret',
                           old_secret: 'old_secret'

run CodebreakerWeb::WebApplication
