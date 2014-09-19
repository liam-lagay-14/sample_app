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

  describe 'edit feature' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      valid_sign_in(user)
      visit edit_user_path(user)
    end

    describe 'page' do
      it { expect(subject).to have_content('Update your profile') }
      it { expect(subject).to have_title('Edit User') }
      it { expect(subject).to have_link('change', href: 'http://gravatar.com/emails')}
    end

    describe 'with invalid information' do
      before { click_button 'Save changes' }

      it { expect(subject).to have_error_message('The form contains 1 error') }
    end

    describe 'with valid information' do
      let(:new_name) { 'New name' }
      let(:email) { 'newname@email.com' }
      before do
        fill_in 'Name', with: new_name
        fill_in 'Email', with: email
        fill_in 'Password', with: user.password
        fill_in 'Confirmation', with: user.password
        click_button 'Save changes'
      end

      it { expect(subject).to have_title(new_name) }
      it { expect(subject).to have_success_message }
      it { expect(subject).to have_link('Sign out', href: signout_path) }
      it { expect(user.reload.name).to eq(new_name) }
      it { expect(user.reload.email).to eq(email) }
    end

    describe 'forbidden attributes' do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before do
        valid_sign_in user, no_capybara: true
        patch user_path(user), params
      end
      it { expect(user.reload).to be_admin }
    end
  end

  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: 'Foo') }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: 'Bar') }

    before { visit user_path(user) }

    it { expect(subject).to have_content(user.name) }
    it { expect(subject).to have_title(user.name) }

    describe 'microposts' do
      it { expect(subject).to have_content(m1.content) }
      it { expect(subject).to have_content(m2.content) }
      it { expect(subject).to have_content(user.microposts.count) }
    end
  end

  describe 'index' do
    before do
      valid_sign_in FactoryGirl.create(:user)
      FactoryGirl.create(:user, name: 'Bob', email: 'Bob@email.com')
      FactoryGirl.create(:user, name: 'Ben', email: 'Ben@email.com')
      visit users_path
    end

    it { expect(subject).to have_title('All users') }
    it { expect(subject).to have_content('All users') }

    it 'should list each user' do
      User.all.each do |user|
        expect(subject).to have_selector('li', text: user.name)
      end
    end

    describe 'pagination' do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { expect(subject).to have_selector('div.pagination') }

      it 'should list each user' do
        User.paginate(page: 1).each do |user|
          expect(subject).to have_selector('li', text: user.name)
        end
      end
    end

    describe 'delete link' do
      it { expect(subject).to_not have_link('delete') }

      describe 'as an admin user' do
        let(:admin) { FactoryGirl.create(:admin) }

        before do
          valid_sign_in admin
          visit users_path
        end

        it { expect(subject).to have_link('delete', href: user_path(User.first)) }
        it 'should be able to delete another user' do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { expect(subject).to_not have_link('delete', href: user_path(:admin)) }
      end
    end
  end


end
