require_relative 'autoload'

use Rack::Static, urls: %w[/bootstrap /jquery], root: 'node_modules'
use Rack::Static, urls: ['/assets'], root: 'views'
use Rack::Session::Cookie, key: 'rack.session',
                           secret: 'secret'
use RackSessionAccess::Middleware

run CodebreakerWeb::WebApplication
