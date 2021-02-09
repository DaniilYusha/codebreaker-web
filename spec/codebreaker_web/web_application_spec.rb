RSpec.describe CodebreakerWeb::WebApplication do
  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:user) { Codebreaker::User.new 'Yusha' }
  let(:difficulty) { Codebreaker::Difficulty.new 'hell' }
  let(:game) { Codebreaker::Game.new user, difficulty }

  before do
    stub_const('OVERRIDABLE_FILE_PATH', 'spec/fixtures/statistics_test.yml')
    stub_const('OVERRIDABLE_DIRECTORY_PATH', 'spec/fixtures')
    stub_const('TEST_GAME_FILE', 'test_game.yml')
    stub_const('TEST_GAME_PATH', "spec/fixtures/#{TEST_GAME_FILE}")
    stub_const('CodebreakerWeb::WebApplication::FILE_PATH', OVERRIDABLE_FILE_PATH)
    stub_const('CodebreakerWeb::GameStorageHepler::DIRECTORY_PATH', OVERRIDABLE_DIRECTORY_PATH)
  end

  after { File.delete(OVERRIDABLE_FILE_PATH) if File.exist?(OVERRIDABLE_FILE_PATH) }

  context 'when unknown path' do
    before { visit '/spec_test' }

    it 'returns 404 code status' do
      expect(status_code).to be 404
    end

    it 'returns 404 page' do
      expect(page).to have_content I18n.t(:not_found)
    end
  end

  context "when move to '/'" do
    before { visit '/' }

    it 'returns 200 code status' do
      expect(status_code).to be 200
    end

    it 'show short game rules' do
      expect(page).to have_content I18n.t :short_rules
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
      expect(page).to have_link I18n.t('links.home')
    end
  end

  context "when move to '/statistics'" do
    let(:success_code) { game.secret_code.join }

    before { visit '/statistics' }

    it 'returns 200 code status' do
      expect(status_code).to be 200
    end

    it 'show table header' do
      expect(page).to have_content I18n.t(:top_players)
    end

    it 'show message about no stats' do
      expect(page).to have_content I18n.t(:no_stats)
    end

    it "has 'Home' link" do
      expect(page).to have_link I18n.t('links.home')
    end
  end

  context 'when starting game' do
    before do
      visit '/'
      fill_in 'player_name', with: user.name
      select difficulty.kind.to_s.capitalize, from: 'level'
      click_button I18n.t('buttons.start_game')
    end

    after { File.delete(File.join(OVERRIDABLE_DIRECTORY_PATH, page.get_rack_session['game_path'])) }

    context 'when game registrated' do
      it 'returns 200 code page' do
        expect(status_code).to be 200
      end

      it 'show greeting message' do
        expect(page).to have_content I18n.t(:greeting, name: user.name)
      end

      it 'show difficulty' do
        expect(page).to have_content difficulty.kind
      end

      it 'show current attempts count' do
        expect(page).to have_content difficulty.current_attempts
      end

      it 'show current hints count' do
        expect(page).to have_content difficulty.current_hints
      end

      it "has 'Show hint!' link" do
        expect(page).to have_link I18n.t('links.hint')
      end

      it "has 'Submit' button" do
        expect(page).to have_button I18n.t('buttons.submit')
      end
    end
  end

  context 'when in game' do
    before do
      File.open(TEST_GAME_PATH, 'w') { |f| f.write game.to_yaml }
      page.set_rack_session(game_path: TEST_GAME_FILE)
      visit '/game'
    end

    after { File.delete TEST_GAME_PATH }

    context 'with input code' do
      let(:code) { '6543' }

      before do
        fill_in('number', with: code)
        click_button I18n.t('buttons.submit')
      end

      it 'returns 200 code page' do
        expect(status_code).to be 200
      end

      it 'change attempts count by 1' do
        expect(page).to have_content(difficulty.current_attempts - 1)
      end

      it 'check result of code input' do
        expect(page.get_rack_session['result']).to eq game.check_attempt(code)
      end
    end

    context 'with take hint' do
      before { click_link I18n.t('links.hint') }

      it 'returns the status 200' do
        expect(status_code).to be 200
      end

      it 'change honts count by 1' do
        expect(page).to have_content(difficulty.current_hints - 1)
      end
    end
  end

  context 'when lose the game' do
    let(:code) { '1234' }

    before do
      game.difficulty.instance_variable_set(:@current_attempts, 1)
      File.open(TEST_GAME_PATH, 'w') { |f| f.write game.to_yaml }
      page.set_rack_session(game_path: TEST_GAME_FILE)
      visit '/game'
      fill_in('number', with: code)
      click_button I18n.t('buttons.submit')
    end

    after { File.delete(TEST_GAME_PATH) if File.exist?(TEST_GAME_PATH) }

    it "redirect to '/lose'" do
      expect(page).to have_current_path('/lose')
    end

    it 'returns the status 200' do
      expect(status_code).to be 200
    end

    it 'show lose message' do
      expect(page).to have_content(I18n.t(:loose, name: user.name))
    end

    it 'show difficulty' do
      expect(page).to have_content difficulty.kind
    end

    it 'show attempts left' do
      game = YAML.load_file(TEST_GAME_PATH)
      expect(page).to have_content "#{game.difficulty.current_attempts}/#{game.difficulty.attempts}"
    end

    it 'show hints left' do
      game = YAML.load_file(TEST_GAME_PATH)
      expect(page).to have_content "#{game.difficulty.current_hints}/#{game.difficulty.hints}"
    end

    it 'show secret code' do
      expect(page).to have_content "#{I18n.t(:code)} #{game.secret_code.join}"
    end

    it 'has play again link' do
      expect(page).to have_link I18n.t('links.play_again')
    end

    it 'has statistics link' do
      expect(page).to have_link I18n.t('links.statistics')
    end

    context 'when click statistics link' do
      it 'remove game file' do
        click_link I18n.t('links.statistics')
        expect(File.exist?(TEST_GAME_PATH)).to eq false
      end
    end
  end

  context 'when win the game' do
    let(:success_code) { game.secret_code.join }

    before do
      File.open(TEST_GAME_PATH, 'w') { |f| f.write game.to_yaml }
      page.set_rack_session(game_path: TEST_GAME_FILE)
      visit '/game'
      fill_in('number', with: success_code)
      click_button I18n.t('buttons.submit')
    end

    after { File.delete TEST_GAME_PATH }

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
      expect(page).to have_content(I18n.t(:win, name: user.name))
    end

    it 'show difficulty' do
      expect(page).to have_content difficulty.kind
    end

    it 'show attempts left' do
      game = YAML.load_file(TEST_GAME_PATH)
      expect(page).to have_content "#{game.difficulty.current_attempts}/#{game.difficulty.attempts}"
    end

    it 'show hints left' do
      game = YAML.load_file(TEST_GAME_PATH)
      expect(page).to have_content "#{game.difficulty.current_hints}/#{game.difficulty.hints}"
    end

    it 'has play again link' do
      expect(page).to have_link I18n.t('links.play_again')
    end

    it 'has statistics link' do
      expect(page).to have_link I18n.t('links.statistics')
    end
  end

  context 'when start game again' do
    let(:success_code) { game.secret_code.join }

    before do
      File.open(TEST_GAME_PATH, 'w') { |f| f.write game.to_yaml }
      page.set_rack_session(game_path: TEST_GAME_FILE)
      visit '/game'
      fill_in('number', with: success_code)
      click_button I18n.t('buttons.submit')
      click_link I18n.t('links.play_again')
    end

    after { File.delete TEST_GAME_PATH }

    it 'returns the status 200' do
      expect(status_code).to be 200
    end

    it "redirect to '/game'" do
      expect(page).to have_current_path('/game')
    end

    it 'clear hint button' do
      expect(page).to have_link I18n.t('links.hint')
    end
  end
end
