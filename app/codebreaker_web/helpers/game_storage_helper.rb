module CodebreakerWeb
  module GameStorageHepler
    GAME_PATH = './app/db/game.yml'.freeze

    def load_game
      File.exist?(GAME_PATH) ? YAML.load_file(GAME_PATH) : nil
    end

    def save_game(game)
      File.open(GAME_PATH, 'w') { |f| f.write game.to_yaml }
    end

    def remove_game
      File.delete GAME_PATH
    end

    def game_present?
      !load_game.nil?
    end

    def clear_data
      remove_game
      session_die
    end
  end
end
