require 'spec_helper'

describe 'Micropost Pages' do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { valid_sign_in user }

  describe 'Micropost creation' do
    before { visit root_path }

    describe 'with invalid information' do
      it { expect { click_button 'Post' }.to_not change(Micropost, :count) }

      describe 'error messages' do
        before { click_button 'Post' }

        it { expect(subject).to have_error_message('error') }
      end
    end

    describe 'with valid information' do
      before { fill_in 'micropost_content', with: 'Test content' }
      it { expect { click_button 'Post' }.to change(Micropost, :count).by(1) }
    end

  end

  describe 'Micropost destruction' do
    before { FactoryGirl.create(:micropost, user: user) }

    describe 'as correct user' do
      before { visit root_path }

      it 'should delete a micropost' do
        expect { click_link 'delete' }.to change(Micropost, :count).by(-1)
      end
    end
  end

end
