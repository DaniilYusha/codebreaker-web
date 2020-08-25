module CodebreakerWeb
  class WebApplication
    include ResponseHelper
    include GameStorageHepler

    attr_reader :statistics

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

    def response
      path = @request.path
      ACTIONS.include?(path) ? send(ACTIONS[path]) : Rack::Response.new(I18n.t(:not_found), 404)
    end

    private

    def initialize(env)
      @request = Rack::Request.new(env)
      @statistics = Codebreaker::StatisticsService.new FILE_PATH
      @game_path = @request.session[:game_path]
      @game = load_game(@game_path)
      @hints = @request.session[:hints].nil? ? [] : @request.session[:hints]
    end

    def menu
      return redirect '/game' if game_present? @game_path

      session_die
      send_respond 'menu', difficulties: Codebreaker::Difficulty::DIFFICULTIES_LIST
    end

    def registrate_game
      @game_path = generate_file_name
      @request.session[:game_path] = @game_path
      user = Codebreaker::User.new get_param('player_name')
      difficulty = Codebreaker::Difficulty.new get_param('level')
      @game = Codebreaker::Game.new(user, difficulty)
      save_game @game, @game_path
      redirect('/game')
    end

    def game
      return redirect '/' unless game_present? @game_path
      return redirect '/lose' if @game.lose?
      return redirect '/win' if @game.win? @request.session[:number]

      send_respond('game', game: load_game(@game_path),
                           result: session_param(:result), hints: session_param(:hints))
    end

    def check_guess
      @request.session[:number] = get_param('number')
      @result = @game.check_attempt get_param('number')
      @request.session[:result] = @result
      save_game @game, @game_path
      redirect '/game'
    end

    def show_hint
      @hints << @game.take_hint
      @request.session[:hints] = @hints
      save_game @game, @game_path
      redirect '/game'
    end

    def lose
      return redirect '/' unless game_present? @game_path
      return redirect '/game' unless @game.lose?

      send_respond 'lose', game: @game
    end

    def win
      return redirect '/' unless game_present? @game_path
      return redirect '/game' unless @game.win? @request.session[:number]

      statistics.store @game
      send_respond 'win', game: @game
    end

    def show_rules
      return redirect '/game' if game_present? @game_path

      send_respond 'rules'
    end

    def show_statistics
      clear_data(@game_path) if @game&.lose? || @game&.win?(@request.session[:number])

      send_respond 'statistics', statistics: statistics.load
    end

    def play_again
      @request.session[:hints], @request.session[:result] = nil
      @game.new_game
      save_game @game, @game_path
      redirect '/game'
    end

    def get_param(param)
      @request.params[param]
    end

    def session_die
      @request.session.clear
    end

    def session_param(param)
      @request.session[param]
    end
  end
end
