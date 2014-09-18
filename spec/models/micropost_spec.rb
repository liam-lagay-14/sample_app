require 'spec_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }

  before { @micropost = user.microposts.build(content: 'Test content') }

  subject { @micropost }

  it { expect(subject).to respond_to(:content) }
  it { expect(subject).to respond_to(:user_id) }
  it { expect(subject).to respond_to(:user) }

  its(:user) { should eq user }

  it { expect(subject).to be_valid }

  describe 'when user id is not valid' do
    before { @micropost.user_id = nil }
    it { expect(subject).to_not be_valid }
  end

  describe 'with blank content' do
    before { @micropost.content = '' }
    it { expect(subject).to_not be_valid }
  end

  describe 'content is more than 140 characters' do
    before { @micropost.content = 'a' * 141 }
    it { expect(subject).to_not be_valid }
  end
end
