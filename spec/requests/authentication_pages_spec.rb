require 'spec_helper'

describe 'Authentication' do
  subject { page }

  describe 'sign in page' do
    before { visit signin_path }

    it { expect(subject).to have_title('Sign in') }
    it { expect(subject).to have_content('Sign in') }
  end

  describe 'signin' do
    before { visit signin_path }

    describe 'with invalid information' do
      before { click_button 'Sign in'}

      it { expect(subject).to have_title('Sign in') }
      it { expect(subject).to have_error_message('Invalid') }

      describe 'after visiting another page' do
        before { click_link "Home" }
        it { expect(subject).to_not have_error_message }
      end
    end

    describe 'with valid information' do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_sign_in(user) }

      it { expect(subject).to have_title(user.name) }
      it { expect(subject).to have_link('Profile', href: user_path(user)) }
      it { expect(subject).to have_link('Sign out', href: signout_path) }
      it { expect(subject).to_not have_link('Sign in', href: signin_path) }

      describe 'followed by signout' do
        before { click_link 'Sign out' }
        it { expect(subject).to have_link('Sign in') }
      end
    end
  end
end
