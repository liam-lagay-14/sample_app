require 'spec_helper'

describe 'Static Pages' do

  subject { page }

  describe 'Home page' do
    before { visit root_path }
    it { expect(subject).to have_content('Sample App') }
    it { expect(subject).to have_title('') }
    it { expect(subject).to_not have_title(full_title('Home')) }
  end

  describe 'Help Page' do
    before { visit help_path }
    it { expect(subject).to have_content('Help') }
    it { expect(subject).to have_title(full_title('Help')) }
  end

  describe 'About Us Page' do
    before { visit about_path }
    it { expect(subject).to have_content('About Us')}
    it { expect(subject).to have_title(full_title('About Us')) }
  end

  describe 'Contact Us Page' do
    before { visit contact_path }
    it { expect(subject).to have_content('Contact Us') }
    it { expect(subject).to have_title(full_title('Contact Us')) }
  end
end
