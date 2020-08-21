require 'bundler'
Bundler.setup

require 'i18n'
require 'erb'
require 'yaml'
require 'tilt'
require 'delegate'
require 'rack'
require 'rack_session_access'
require 'codebreaker'

require_relative 'config/i18n'

require_relative 'app/codebreaker_web/helpers/data_management_helper'
require_relative 'app/codebreaker_web/helpers/game_storage_helper'

require_relative 'app/codebreaker_web/web_application'
