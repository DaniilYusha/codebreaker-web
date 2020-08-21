module CodebreakerWeb
  module GameStorageHepler
    DIRECTORY_PATH = './app/db'.freeze
    FILE_PATH = './app/db/statistics.yml'.freeze

    def load_game(filename)
      return nil if filename.nil?

      YAML.load_file(path_to_game(filename))
    end

    def save_game(game, filename)
      File.open(path_to_game(filename), 'w') { |f| f.write game.to_yaml }
    end

    def generate_file_name
      "game_#{8.times.map { rand(10) }.join}.yml"
    end

    def remove_game(filename)
      File.delete path_to_game(filename)
    end

    def game_present?(filename)
      !!load_game(filename)
    end

    def clear_data(filename)
      remove_game filename
      session_die
    end

    def path_to_game(filename)
      File.join(DIRECTORY_PATH, filename)
    end
  end
end
