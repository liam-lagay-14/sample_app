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
      it { expect(subject).to have_link('Users', href: users_path) }
      it { expect(subject).to have_link('Profile', href: user_path(user)) }
      it { expect(subject).to have_link('Settings', href: edit_user_path(user)) }
      it { expect(subject).to have_link('Sign out', href: signout_path) }
      it { expect(subject).to_not have_link('Sign in', href: signin_path) }

      describe 'followed by signout' do
        before { click_link 'Sign out' }
        it { expect(subject).to have_link('Sign in') }
      end
    end

    describe 'authorization' do
      describe 'for non-signed in users' do
        let(:user) { FactoryGirl.create(:user) }

        it { expect(subject).to_not have_link('Profile', href: user_path(user)) }
        it { expect(subject).to_not have_link('Settings', href: edit_user_path(user)) }

        describe 'when attempting to visit a protected page' do
          before do
            valid_sign_in user
            visit edit_user_path(user)
          end

          describe 'after signing in' do
            it { expect(subject).to have_title('Edit User') }
          end

          describe 'when signing in again' do
            before do
              click_link 'Sign out'
              visit signin_path
              valid_sign_in user
            end

            it { expect(subject).to have_title(user.name) }
          end
        end

        describe 'in the Users controller' do

          describe 'visiting the edit page' do
            before { visit edit_user_path(user) }
            it { expect(subject).to have_title('Sign in') }
          end

          describe 'submitting to the update action' do
            before { patch user_path(user) }
            it { expect(current_path).to eq(signin_path) }
          end

          describe 'visiting the user index' do
            before { visit users_path }
            it { expect(subject).to have_title('Sign in')}
          end
        end

        describe 'in the Microposts controller' do
          describe 'submitting to the create action' do
            before { post microposts_path }
            it { expect(response.redirect?).to eq(true) }
            it { expect(redirect_to_url).to eq(signin_url)}
          end

          describe 'submitting to the destroy action' do
            before { delete micropost_path(FactoryGirl.create(:micropost)) }
            it { expect(response.redirect?).to eq(true) }
            it { expect(redirect_to_url).to eq(signin_url) }
          end
        end
      end

      describe 'can not delete other users posts' do
        let(:invalid_user) { FactoryGirl.create(:user) }
        before { visit user_path(invalid_user) }
        it { expect(subject).to_not have_link('delete')}
      end

      describe 'as the wrong user' do
        let(:user) { FactoryGirl.create(:user) }
        let(:wrong_user) { FactoryGirl.create(:user, email: 'wrong@example.com') }
        before { valid_sign_in user, no_capybara: true }

        describe 'submitting a GET request to the Users#edit action' do
          before { get edit_user_path(wrong_user) }
          it { expect(current_path).to_not eq(edit_user_path(user)) }
          it { expect(subject).to_not have_title('Edit User') }
          it { expect(response.redirect?).to eq(true) }
          it { expect(redirect_to_url).to eq(root_url) }
        end

        describe 'submitting a PATCH request to the Users#edit action' do
          before { patch user_path(wrong_user) }
          it { expect(response.redirect?).to eq(true) }
          it { expect(redirect_to_url).to eq(root_url) }
        end
      end

      describe 'as non-admin user' do
        let(:user) { FactoryGirl.create(:user) }
        let(:non_admin) { FactoryGirl.create(:user) }

        before { valid_sign_in non_admin, no_capybara: true }

        describe 'sending a DELETE request to users#destroy action' do
          before { delete user_path(user) }
          it { expect(response.redirect?).to eq(true) }
          it { expect(redirect_to_url).to eq(root_url) }
        end
      end
    end
  end
end
