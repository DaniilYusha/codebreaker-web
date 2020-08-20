require_relative '../spec_helper'

RSpec.describe CodebreakerWeb::WebApplication do
  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:user) { Codebreaker::User.new 'Yusha' }
  let(:difficulty) { Codebreaker::Difficulty.new 'hell' }
  let(:game) { Codebreaker::Game.new user, difficulty }

  before do
    stub_const('OVERRIDABLE_FILE_PATH', 'spec/fixtures/statistics_test.yml')
    stub_const('OVERRIDABLE_GAME_PATH', 'spec/fixtures/game_test.yml')
    stub_const('CodebreakerWeb::WebApplication::FILE_PATH', OVERRIDABLE_FILE_PATH)
    stub_const('CodebreakerWeb::GameStorageHepler::GAME_PATH', OVERRIDABLE_GAME_PATH)
  end

  after { File.delete(OVERRIDABLE_FILE_PATH) if File.exist?(OVERRIDABLE_FILE_PATH) }

  context 'when unknown path' do
    before { visit '/spec_test' }

    it 'returns 404 code status' do
      expect(status_code).to be 404
    end

    it 'returns 404 page' do
      expect(page).to have_content 'Not Found'
    end
  end

  context "when move to '/'" do
    before { visit '/' }

    it 'returns 200 code status' do
      expect(status_code).to be 200
    end

    it 'show short game rules' do
      expect(page).to have_content 'Try to guess 4-digit number, that consists of numbers in a range from 1 to 6.'
    end

    context 'with trying go to game page' do
      it "redirect to '/'" do
        visit '/game'
        expect(page).to have_current_path '/'
      end
    end

    context 'with trying go to win page' do
      it "redirect to '/'" do
        visit '/win'
        expect(page).to have_current_path '/'
      end
    end

    context 'with trying go to lose page' do
      it "redirect to '/'" do
        visit '/lose'
        expect(page).to have_current_path '/'
      end
    end
  end

  context "when move to '/rules'" do
    before { visit '/rules' }

    it 'returns 200 code status' do
      expect(status_code).to be 200
    end

    it 'show codebreaker rules' do
      expect(page).to have_content I18n.t(:rules)
    end

    it "has 'Home' link" do
      expect(page).to have_link 'Home'
    end
  end

  context "when move to '/statistics'" do
    before { visit '/statistics' }

    it 'returns 200 code status' do
      expect(status_code).to be 200
    end

    it 'show table header' do
      expect(page).to have_content 'Top of Players:'
    end

    it 'show message about no stats' do
      expect(page).to have_content 'There are no winners yet! Be the first!'
    end

    it "has 'Home' link" do
      expect(page).to have_link 'Home'
    end
  end

  context 'when starting game' do
    before do
      visit '/'
      fill_in 'player_name', with: user.name
      select difficulty.kind.to_s.capitalize, from: 'level'
      click_button 'Start the game!'
    end

    after { File.delete OVERRIDABLE_GAME_PATH }

    context 'when game registrated' do
      it 'returns 200 code page' do
        expect(status_code).to be 200
      end

      it 'show greeting message' do
        expect(page).to have_content "Hello, #{user.name}!"
      end

      it 'show difficulty' do
        expect(page).to have_content "Level: #{difficulty.kind}"
      end

      it 'show current attempts count' do
        expect(page).to have_content "Attempts: #{difficulty.current_attempts}"
      end

      it 'show current hints count' do
        expect(page).to have_content "Hints: #{difficulty.current_hints}"
      end

      it "has 'Show hint!' link" do
        expect(page).to have_link 'Show hint!'
      end

      it "has 'Submit' button" do
        expect(page).to have_button 'Submit'
      end
    end
  end

  context 'when input code' do
    let(:code) { '6543' }

    before do
      File.open(OVERRIDABLE_GAME_PATH, 'w') { |f| f.write game.to_yaml }
      visit '/game'
      fill_in('number', with: code)
      click_button 'Submit'
    end

    after { File.delete OVERRIDABLE_GAME_PATH }

    it 'returns 200 code page' do
      expect(status_code).to be 200
    end

    it 'change attempts count by 1' do
      expect(page).to have_content "Attempts: #{difficulty.current_attempts - 1}"
    end
  end

  context 'when take hint' do
    before do
      File.open(OVERRIDABLE_GAME_PATH, 'w') { |f| f.write game.to_yaml }
      visit '/game'
      click_link 'Show hint!'
    end

    after { File.delete OVERRIDABLE_GAME_PATH }

    it 'returns the status 200' do
      expect(status_code).to be 200
    end

    it 'change honts count by 1' do
      expect(page).to have_content "Hints: #{difficulty.current_hints - 1}"
    end
  end

  context 'when lose the game' do
    let(:code) { '1234' }

    before do
      game.difficulty.instance_variable_set(:@current_attempts, 1)
      File.open(OVERRIDABLE_GAME_PATH, 'w') { |f| f.write game.to_yaml }
      visit '/game'
      fill_in('number', with: code)
      click_button 'Submit'
    end

    after { File.delete OVERRIDABLE_GAME_PATH }

    it "redirect to '/lose'" do
      expect(page).to have_current_path('/lose')
    end

    it 'returns the status 200' do
      expect(status_code).to be 200
    end

    it 'show lose message' do
      expect(page).to have_content "Oops, #{user.name}! You lose the game!"
    end

    it 'show difficulty' do
      expect(page).to have_content difficulty.kind
    end

    it 'show attempts left' do
      game = YAML.load_file(OVERRIDABLE_GAME_PATH)
      expect(page).to have_content "#{game.difficulty.current_attempts}/#{game.difficulty.attempts}"
    end

    it 'show hints left' do
      game = YAML.load_file(OVERRIDABLE_GAME_PATH)
      expect(page).to have_content "#{game.difficulty.current_hints}/#{game.difficulty.hints}"
    end

    it 'show secret code' do
      expect(page).to have_content "The code was #{game.secret_code.join}"
    end

    it 'has play again link' do
      expect(page).to have_link 'Play again!'
    end

    it 'has statistics link' do
      expect(page).to have_link 'Statistics'
    end
  end

  context 'when win the game' do
    let(:success_code) { game.secret_code.join }

    before do
      File.open(OVERRIDABLE_GAME_PATH, 'w') { |f| f.write game.to_yaml }
      visit '/game'
      fill_in('number', with: success_code)
      click_button 'Submit'
    end

    after { File.delete OVERRIDABLE_GAME_PATH }

    it "redirect to '/win'" do
      expect(page).to have_current_path('/win')
    end

    it 'saves results to file' do
      expect(File.exist?(OVERRIDABLE_FILE_PATH)).to be true
    end

    it 'file item is an instance of Hash' do
      expect(YAML.load_file(OVERRIDABLE_FILE_PATH).first.class).to eq Hash
    end

    it 'returns the status 200' do
      expect(status_code).to be 200
    end

    it 'show congratulations message' do
      expect(page).to have_content "Congratulations, #{user.name}! You won the game!"
    end

    it 'show difficulty' do
      expect(page).to have_content difficulty.kind
    end

    it 'show attempts left' do
      game = YAML.load_file(OVERRIDABLE_GAME_PATH)
      expect(page).to have_content "#{game.difficulty.current_attempts}/#{game.difficulty.attempts}"
    end

    it 'show hints left' do
      game = YAML.load_file(OVERRIDABLE_GAME_PATH)
      expect(page).to have_content "#{game.difficulty.current_hints}/#{game.difficulty.hints}"
    end

    it 'has play again link' do
      expect(page).to have_link 'Play again!'
    end

    it 'has statistics link' do
      expect(page).to have_link 'Statistics'
    end
  end

  context 'when start game again' do
    let(:success_code) { game.secret_code.join }

    before do
      File.open(OVERRIDABLE_GAME_PATH, 'w') { |f| f.write game.to_yaml }
      visit '/game'
      fill_in('number', with: success_code)
      click_button 'Submit'
      click_link 'Play again!'
    end

    after { File.delete OVERRIDABLE_GAME_PATH }

    it 'returns the status 200' do
      expect(status_code).to be 200
    end

    it "redirect to '/game'" do
      expect(page).to have_current_path('/game')
    end

    it 'clear hint button' do
      expect(page).to have_link 'Show hint!'
    end
  end
end
