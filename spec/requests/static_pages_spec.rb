require 'spec_helper'

describe 'Static Pages' do

  let(:base_title) { 'Ruby on Rails Tutorial Sample App' }

  describe 'Home page' do
    it 'should have the content sample app' do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      visit 'static_pages/home'
      expect(page).to have_content('Sample App')
    end

    it 'should have the title Home' do
      visit 'static_pages/home'
      expect(page).to have_title("#{base_title} | Home")
    end
  end

  describe 'Help Page' do
    it 'should have the content Help' do
      visit 'static_pages/help'
      expect(page).to have_content('Help')
    end

    it 'should have the title Help' do
      visit 'static_pages/help'
      expect(page).to have_title("#{base_title} | Help")
    end
  end

  describe 'About Us Page' do
    it 'should have the content About Us' do
      visit 'static_pages/about'
      expect(page).to have_content('About Us')
    end

    it 'should have the title About Us' do
      visit 'static_pages/about'
      expect(page).to have_title("#{base_title} | About Us")
    end
  end

  describe 'Contact Us Page' do
    it 'should have the content Contact Us' do
      visit 'static_pages/contact'
      expect(page).to have_content('Contact Us')
    end

    it 'should have the title Contact Us' do
      visit 'static_pages/contact'

      expect(page).to have_title("#{base_title} | Contact Us")
    end
  end
end
