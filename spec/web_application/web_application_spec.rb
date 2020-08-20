require_relative '../spec_helper'

RSpec.describe Middlewares::WebApplication do
  let(:app) { Rack::Builder.parse_file('config.ru').first }
  let(:user) { Codebreaker::User.new 'Yusha' }
  let(:difficulty) { Codebreaker::Difficulty.new 'hell' }
  let(:game) { Codebreaker::Game.new user, difficulty }

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

    it 'show message about no stats' do
      expect(page).to have_content 'Top of Players:'
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

    context 'when game registrated' do
      it 'returns 200 code page' do
        expect(status_code).to be 200
      end

      it 'show hello message' do
        expect(page).to have_content "Hello, #{user.name}!"
      end
    end
  end
end
