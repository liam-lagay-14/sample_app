require 'spec_helper'

describe User do
  before { @user = User.create(name: 'Liam Lagay', email: 'liam.lagay@gmail.com', password: 'foobar', password_confirmation: 'foobar') }

  subject { @user }

  it { expect(subject).to respond_to(:name) }

  it { expect(subject).to respond_to(:email) }

  it { expect(subject).to respond_to(:password_digest) }

  it { expect(subject).to respond_to(:password) }

  it { expect(subject).to respond_to(:password_confirmation) }

  it { expect(subject).to respond_to(:authenticate) }

  it { expect(subject).to respond_to(:admin) }

  it { expect(subject).to respond_to(:microposts) }

  it { expect(subject).to respond_to(:feed) }

  it { expect(subject).to respond_to(:relationships) }

  it { expect(subject).to respond_to(:followed_users) }

  it { expect(subject).to respond_to(:following?) }

  it { expect(subject).to respond_to(:follow!) }

  it { expect(subject).to respond_to(:reverse_relationships) }

  it { expect(subject).to respond_to(:remember_token)}


  it 'should be valid' do
    expect(subject).to be_valid

    expect(subject).to_not be_admin
  end

  describe 'when name is not present' do
    before { @user.name = '' }

    it { expect(subject).to_not be_valid }
  end

  describe 'when email is not present' do
    before { @user.email = '' }
    it { expect(subject).to_not be_valid }
  end

  describe 'when password is not present' do
    before { @user.password = '', @user.password_confirmation = '' }
    it { expect(subject).to_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = 'mismatch' }
    it { expect(subject).to_not be_valid }
  end

  describe 'when name is too long' do
    before { @user.name = "a" * 51 }
    it { expect(subject).to_not be_valid }
  end

  describe 'when email format is invalid' do
    it 'should be invalid' do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com, foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'when email format is valid' do
    it 'should be valid' do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(subject).to be_valid
      end
    end
  end

  describe 'when email address is already taken' do
    let(:user_with_duplicate_email) { @user.dup }

    before do
      user_with_duplicate_email.email = @user.email.upcase
      user_with_duplicate_email.save
    end

    it { expect(user_with_duplicate_email).to_not be_valid }
  end

  describe 'return value of authenticate method' do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe 'with valid password' do
      it { expect(found_user).to eq(found_user.authenticate(@user.password)) }
    end

    describe 'with invalid password' do
      let(:user_with_invalid_password) { found_user.authenticate('invalid') }
      it { expect(found_user).not_to eq(user_with_invalid_password) }
      it { expect(user_with_invalid_password).to be_false }
    end
  end

  describe 'with a password that is too short' do
    before { @user.password = @user.password_confirmation = 'a' * 5 }
    it { expect(subject).not_to be_valid }
  end

  describe 'when email is mixed case' do
    let(:user_email_mixed) { 'TeST@eMaIl.COM' }

    it 'should be saved as lowercase' do
      @user.email = user_email_mixed
      @user.save
      expect(subject.reload.email).to eq(user_email_mixed.downcase)
    end
  end

  describe 'remember me token' do
    before { @user.save }
    it { expect(subject.remember_token).to_not be_blank }
  end

  describe 'with admin attribute set to true' do
    before do
      @user.save!
      @user.toggle(:admin)
    end

    it { expect(subject).to be_admin }
  end

  describe 'micropost associations' do
    before { subject.save }
    let!(:older_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago ) }
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }

    it { expect(subject.microposts.to_a).to eq([newer_micropost, older_micropost]) }

    it 'should destroy associated microposts' do
      microposts = subject.microposts.to_a
      @user.destroy
      expect(microposts).to_not be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe 'following' do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { expect(subject).to be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe 'and unfollowing' do
      before { @user.unfollow!(other_user) }

      it { expect(subject).to_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end

    describe 'followed user' do
      subject { other_user }
      its(:followers) { should include(@user) }
    end
  end

end
