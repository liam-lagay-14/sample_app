require 'spec_helper'

describe 'Static Pages' do

  subject { page }

  shared_examples_for 'All Static Pages' do
    it { expect(subject).to have_selector('h1', text: heading) }
    it { expect(subject).to have_title(full_title(page_title)) }
  end

  describe 'Home page' do
    before { visit root_path }
    let(:heading) { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like 'All Static Pages'

    it { expect(subject).to_not have_title(full_title('Home')) }

    describe 'for signed-in users' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: 'Test content 1')
        FactoryGirl.create(:micropost, user: user, content: 'Test content 2')
        valid_sign_in user
        visit root_path
      end

      it 'should render the users feed' do
        user.feed.each do |item|
          expect(subject).to have_selector("li##{item.id}", text: item.content)
        end
      end

      it { expect(subject).to have_content('2 microposts') }

      describe 'for signed-in users with a single micropost' do
        let(:second_user) { FactoryGirl.create(:user, email: 'Billbob@email.com') }
        before do
          FactoryGirl.create(:micropost, user: second_user, content: 'Test content for Bill bob')
          valid_sign_in second_user
          visit root_path
        end

        it { expect(subject).to have_content('1 micropost') }
      end

      describe 'follower/following counts' do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { expect(subject).to have_link('0 following', href: following_user_path(user)) }
        it { expect(subject).to have_link('1 followers', href: followers_user_path(user)) }
      end
    end
  end

  describe 'Help Page' do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like 'All Static Pages'
  end

  describe 'About Us Page' do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }

    it_should_behave_like 'All Static Pages'
  end

  describe 'Contact Us Page' do
    before { visit contact_path }
    let(:heading) { 'Contact Us' }
    let(:page_title) { 'Contact Us' }

    it_should_behave_like 'All Static Pages'
  end

  it 'should have the right links on the layout' do
    visit root_path
    click_link 'About'
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign Up'))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
  end

  describe 'micropost pagination' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      31.times { FactoryGirl.create(:micropost, user: user) }
      valid_sign_in user
      visit root_path
    end
    after { user.microposts.destroy_all }
    it { expect(subject).to have_selector('div.pagination')}
  end
end


