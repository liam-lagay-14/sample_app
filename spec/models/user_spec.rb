require 'spec_helper'

describe User do
  before { @user = User.create(name: 'Liam Lagay', email: 'liam.lagay@gmail.com', password: 'foobar', password_confirmation: 'foobar') }

  subject { @user }

  it { expect(@user).to respond_to(:name) }

  it { expect(@user).to respond_to(:email) }

  it { expect(@user).to respond_to(:password_digest) }

  it { expect(@user).to respond_to(:password) }

  it { expect(@user).to respond_to(:password_confirmation) }

  it { expect(@user).to respond_to(:authenticate) }


  it 'should be valid' do
    expect(@user).to be_valid
  end

  describe 'when name is not present' do
    before { @user.name = '' }

    it { expect(@user).to_not be_valid }
  end

  describe 'when email is not present' do
    before { @user.email = '' }
    it { expect(@user).to_not be_valid }
  end

  describe 'when password is not present' do
    before { @user.password = '', @user.password_confirmation = '' }
    it { expect(@user).to_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = 'mismatch' }
    it { expect(@user).to_not be_valid }
  end

  describe 'when name is too long' do
    before { @user.name = "a" * 51 }
    it { expect(@user).to_not be_valid }
  end

  describe 'when email format is invalid' do
    it 'should be invalid' do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com, foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe 'when email format is valid' do
    it 'should be valid' do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
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
    it { expect(@user).not_to be_valid }
  end

  describe 'when email is mixed case' do
    let(:user_email_mixed) { 'TeST@eMaIl.COM' }

    it 'should be saved as lowercase' do
      @user.email = user_email_mixed
      @user.save
      expect(@user.reload.email).to eq(user_email_mixed.downcase)
    end
  end

end
