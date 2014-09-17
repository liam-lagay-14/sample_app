require 'spec_helper'

describe 'User Pages' do

  subject { page }

  describe 'sign up page' do
    before { visit signup_path }
    it { expect(subject).to have_content('Sign Up') }
    it { expect(subject).to have_title(full_title('Sign Up'))}
  end

  describe 'signup' do
    before { visit signup_path }

    let(:submit) { 'Create my account' }

    describe 'with invalid information' do
      it 'should not create a user' do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe 'after submission' do
        before { click_button submit }

        it { expect(subject).to have_title('Sign Up') }
        it { expect(subject).to have_error_message('The form contains 5 errors') }
      end
    end

    describe 'with valid information' do
      before do
        fill_in 'Name', with: 'Liam Lagay'
        fill_in 'Email', with: 'liam.lagay@gmail.com'
        fill_in 'Password', with: 'foobar'
        fill_in 'Confirmation', with: 'foobar'
      end
      it 'should create a user' do
        expect { click_button submit }.to change(User, :count)
      end

      describe 'after saving a user' do
        before { click_button submit }

        let(:user) { User.find_by(email: 'liam.lagay@gmail.com') }

        it { expect(current_path).to eq(user_path(user)) }
        it { expect(subject).to have_link('Sign out')}
        it { expect(subject).to have_title(user.name) }
        it { expect(subject).to have_success_message('Welcome')}

      end
    end
  end

  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { expect(subject).to have_content(user.name) }
    it { expect(subject).to have_title(user.name) }
  end
end
