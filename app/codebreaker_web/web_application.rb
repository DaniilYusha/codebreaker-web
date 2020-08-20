module CodebreakerWeb
  class WebApplication
    include DataManagementHelper
    include GameStorageHepler

    attr_reader :statistics

    FILE_PATH = './app/db/statistics.yml'.freeze
    ACTIONS = {
      '/' => :menu,
      '/registration' => :registrate_game,
      '/game' => :game,
      '/submit_answer' => :check_guess,
      '/show_hint' => :show_hint,
      '/lose' => :lose,
      '/win' => :win,
      '/rules' => :show_rules,
      '/statistics' => :show_statistics,
      '/play_again' => :play_again
    }.freeze

    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @request = Rack::Request.new(env)
      @statistics = Codebreaker::StatisticsService.new FILE_PATH
      @game = load_game
      @hints = @request.session[:hints].nil? ? [] : @request.session[:hints]
    end

    def response
      path = @request.path
      ACTIONS.include?(path) ? send(ACTIONS[path]) : Rack::Response.new(I18n.t(:not_found), 404)
    end

    private

    def menu
      return redirect '/game' if game_present?

      send_respond 'menu'
    end

    def registrate_game
      user = Codebreaker::User.new get_param('player_name')
      difficulty = Codebreaker::Difficulty.new get_param('level')
      @game = Codebreaker::Game.new(user, difficulty)
      save_game @game
      redirect('/game')
    end

    def game
      return redirect '/' unless game_present?
      return redirect '/lose' if @game.lose?
      return redirect '/win' if @game.win? @request.session[:number]

      send_respond 'game', game: load_game, result: session_param(:result), hints: session_param(:hints)
    end

    def check_guess
      @request.session[:number] = get_param('number')
      @result = @game.check_attempt get_param('number')
      @request.session[:result] = @result
      save_game @game
      redirect '/game'
    end

    def show_hint
      @hints << @game.take_hint
      @request.session[:hints] = @hints
      save_game @game
      redirect '/game'
    end

    def lose
      return redirect '/' unless game_present?
      return redirect '/game' unless @game.lose?

      send_respond 'lose', game: @game
    end

    def win
      return redirect '/' unless game_present?
      return redirect '/game' unless @game.win? @request.session[:number]

      statistics.store @game
      send_respond 'win', game: @game
    end

    def show_rules
      return redirect '/game' if game_present?

      send_respond 'rules'
    end

    def show_statistics
      clear_data if @game&.lose? || @game&.win?(@request.session[:number])
      return redirect '/game' if game_present?

      send_respond 'statistics', statistics: statistics.load
    end

    def play_again
      clear_data
      @game.new_game
      save_game @game
      redirect '/game'
    end

    def send_respond(view, **args)
      Rack::Response.new(render(view, **args))
    end

    def render(template, **args)
      Tilt.new(template_path(template)).render(Object.new, **args)
    end

    def template_path(template)
      File.expand_path("../../views/#{template}.html.erb", __FILE__)
    end

    def redirect(path)
      Rack::Response.new { |response| response.redirect(path) }
    end
  end
end
