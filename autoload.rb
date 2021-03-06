require 'bundler'
Bundler.setup

require 'i18n'
require 'erb'
require 'yaml'
require 'tilt'
require 'delegate'
require 'rack'
require 'securerandom'

require 'rack_session_access' unless ENV.fetch('RACK_ENV', 'development') == 'production'

require 'codebreaker'

require_relative 'config/i18n'

require_relative 'app/codebreaker_web/helpers/game_storage_helper'
require_relative 'app/codebreaker_web/helpers/response_helper'

require_relative 'app/codebreaker_web/web_application'
